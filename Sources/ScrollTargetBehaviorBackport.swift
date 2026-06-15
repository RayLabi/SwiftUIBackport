#if canImport(SwiftUI)
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - ScrollView 扩展 滚动吸附行为

/// 镜像系统 ScrollTargetBehavior 的两种常用行为
/// - paging: 分页滚动，每次滚动一页
/// - viewAligned: 按视图对齐滚动，内容会吸附到指定对齐方式
public enum ScrollTargetBehaviorBackport: Equatable {
    case paging
    case viewAligned(alignment: Alignment = .center)
}

public extension ScrollView {
    /// ScrollTargetBehavior 的 backport 实现，兼容 iOS 17 以下
    /// - Parameters:
    ///   - behavior: 滚动行为
    ///   - itemLength: 单个项的长度（用于 viewAligned 模式）
    @MainActor @ViewBuilder
    func scrollTargetBehaviorBackport(
        _ behavior: ScrollTargetBehaviorBackport,
        itemLength: CGFloat? = nil
    ) -> some View {
        if #available(iOS 17.0, *) {
            // iOS 17+ 使用原生 API
            switch behavior {
            case .paging:
                self.scrollTargetBehavior(.paging)
            case .viewAligned(let align):
                self.scrollTargetBehavior(.viewAligned)
            }
        } else {
            // iOS 16 及以下的 Backport 实现
            self.modifier(ScrollTargetBehaviorBackportModifier(
                behavior: behavior,
                itemLength: itemLength
            ))
        }
    }
}

// MARK: - iOS 16 及以下 Backport 修饰符

private struct ScrollTargetBehaviorBackportModifier: ViewModifier {
    let behavior: ScrollTargetBehaviorBackport
    let itemLength: CGFloat?
    
    func body(content: Content) -> some View {
        switch behavior {
        case .paging:
            // 分页模式：应用分页修饰符
            content.modifier(PagingBackportModifier())
        case .viewAligned(let alignment):
            // 视图对齐模式：应用对齐修饰符
            content.modifier(ViewAlignedBackportModifier(alignment: alignment, itemLength: itemLength))
        }
    }
}

// MARK: - 分页 Backport 修饰符

private struct PagingBackportModifier: ViewModifier {
    func body(content: Content) -> some View {
        // 分页实现：通过内省获取 UIScrollView 并启用分页
        #if canImport(UIKit)
        content.background(
            PagingScrollViewConfigurer()
        )
        #else
        content
        #endif
    }
}

// MARK: - 视图对齐 Backport 修饰符

private struct ViewAlignedBackportModifier: ViewModifier {
    let alignment: Alignment
    let itemLength: CGFloat?
    
    func body(content: Content) -> some View {
        // 视图对齐实现：通过内省获取 UIScrollView 并设置 delegate
        #if canImport(UIKit)
        content.background(
            ScrollViewConfigurer(alignment: alignment, itemLength: itemLength)
        )
        #else
        content
        #endif
    }
}

#if canImport(UIKit)

// MARK: - 分页 ScrollView 配置器

private struct PagingScrollViewConfigurer: View {
    var body: some View {
        IntrospectionView { view in
            enablePaging(in: view)
        }
    }
    
    private func enablePaging(in view: UIView) {
        if let scrollView = view as? UIScrollView {
            scrollView.isPagingEnabled = true
        }
    }
}

// MARK: - ScrollView 配置器（内省助手）

private struct ScrollViewConfigurer: View {
    let alignment: Alignment
    let itemLength: CGFloat?
    
    var body: some View {
        IntrospectionView { view in
            configureScrollViewDelegate(in: view)
        }
    }
    
    private func configureScrollViewDelegate(in view: UIView) {
        guard let itemLength = itemLength, itemLength > 0 else { return }
        
        // 如果传入的就是 ScrollView，直接使用
        if let scrollView = view as? UIScrollView {
            let delegate = ScrollTargetAlignmentDelegate(
                itemLength: itemLength,
                alignment: alignment
            )
            scrollView.delegate = delegate
            
            // 将 delegate 保存在 scrollView 上以防止被释放
            objc_setAssociatedObject(
                scrollView,
                &scrollViewDelegateKey,
                delegate,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

@MainActor private var scrollViewDelegateKey: UInt8 = 0

// MARK: - 内省视图

private struct IntrospectionView: UIViewRepresentable {
    let configure: (UIView) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        
        // 第一次延迟配置
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            attemptConfiguration(view)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            attemptConfiguration(uiView)
        }
    }
    
    private func attemptConfiguration(_ view: UIView) {
        // 从当前视图开始向上查找
        var current: UIView? = view
        var attempts = 0
        let maxAttempts = 50
        
        while current != nil && attempts < maxAttempts {
            if let scrollView = findScrollView(in: current!) {
                configure(scrollView)
                return
            }
            current = current?.superview
            attempts += 1
        }
        
        // 如果向上查找失败，尝试从根窗口向下查找
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            findAndConfigureScrollView(in: window)
        }
    }
    
    private func findAndConfigureScrollView(in view: UIView) {
        if let scrollView = view as? UIScrollView {
            configure(scrollView)
            return
        }
        for subview in view.subviews {
            findAndConfigureScrollView(in: subview)
        }
    }
    
    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let scrollView = findScrollView(in: subview) {
                return scrollView
            }
        }
        return nil
    }
}

// MARK: - ScrollView 对齐委托

private class ScrollTargetAlignmentDelegate: NSObject, UIScrollViewDelegate {
    let itemLength: CGFloat
    let alignment: Alignment
    
    init(itemLength: CGFloat, alignment: Alignment) {
        self.itemLength = itemLength
        self.alignment = alignment
        super.init()
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        handleScrollTargetAlignment(
            scrollView: scrollView,
            targetContentOffset: targetContentOffset
        )
    }
    
    private func handleScrollTargetAlignment(
        scrollView: UIScrollView,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let isHorizontal = scrollView.bounds.width > scrollView.bounds.height
        
        if isHorizontal {
            // 水平滚动：根据 itemLength 对齐
            let proposedOffset = targetContentOffset.pointee.x
            let alignedOffset = round(proposedOffset / itemLength) * itemLength
            targetContentOffset.pointee.x = alignedOffset
        } else {
            // 竖直滚动：根据 itemLength 对齐
            let proposedOffset = targetContentOffset.pointee.y
            let alignedOffset = round(proposedOffset / itemLength) * itemLength
            targetContentOffset.pointee.y = alignedOffset
        }
    }
}

#endif

#endif
