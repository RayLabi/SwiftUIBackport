#if canImport(SwiftUI)
import SwiftUI

// MARK: - 1. 对iOS26齐原生Glass的枚举类型（限定支持的样式）
fileprivate enum GlassBackportType: CaseIterable, Sendable {
case regular
case clear
}

// MARK: - 2. 核心封装结构体：对外暴露和原生Glass一致的接口
public struct GlassBackport: Equatable, Sendable {
    fileprivate var _interactive: Bool = false // 记录交互态配置
    private let type: GlassBackportType
    
    /// 对外暴露和原生一致的静态属性
    public static var regular: GlassBackport { get {
        return GlassBackport(type: .regular)
    } }
    
    public static var clear: GlassBackport { get {
        return GlassBackport(type: .clear)
    } }
    
    // iOS 26+映射到原生Glass
    @available(iOS 26.0, *)
    fileprivate var nativeGlass: Glass {
        switch self.type {
        case .regular: return Glass.regular
        case .clear: return Glass.clear
        }
    }
    
    // 低版本 SwiftUI Material 兼容映射
    @available(iOS, introduced: 15, deprecated: 26)
    fileprivate var fallbackMaterial: Material {
        switch self.type {
        case .regular: return .regularMaterial
        case .clear: return .ultraThinMaterial
        }
    }
    
    /// 对齐原生Glass的interactive配置能力
    public func interactive(_ isEnabled: Bool = true) -> GlassBackport {
        var copy = self
        copy._interactive = isEnabled
        return copy
    }
    
    public static func == (a: Self, b: Self) -> Bool {
        return a._interactive == b._interactive && a.type == b.type
    }
}

// MARK: - iOS26 默认玻璃形状 DefaultGlassEffectShape （胶囊形 + 连续圆角）兼容封装
/// iOS26 glassEffect 默认
/// ▿ DefaultGlassEffectShape
/// ▿ base : Capsule
///  - style : SwiftUI.RoundedCornerStyle.continuous
public struct DefaultGlassEffectShapeBackport: Shape {
    public init() {}
    
    /// ▿ Storage
    /// - roundedRect : FixedRoundedRect
    /// - style : SwiftUI.RoundedCornerStyle.continuous
    /// 核心：圆角尺寸设为宽高的一半，实现胶囊形（和原生DefaultGlassEffectShape一致）
    public func path(in rect: CGRect) -> Path {
        return Path(roundedRect: rect, cornerSize: CGSize(width: rect.width/2.0, height: rect.height/2.0), style: .continuous)
    }
}

// MARK: - View 扩展：backport glassEffect(_:in:)
public extension View {
    /// Backport iOS26 .glassEffect API
    /// - Parameters:
    ///   - glass: 玻璃质感分级，默认 .regular
    ///   - shape: 玻璃裁剪形状，默认 DefaultGlassEffectShape() 16pt圆角矩形
    /// - Returns: 应用玻璃磨砂材质的视图
    @ViewBuilder
    func glassEffectBackport(_ glass: GlassBackport = .regular, in shape: some Shape = DefaultGlassEffectShapeBackport())  -> some View {
        if #available(iOS 26.0, *) {
            // iOS26+ 直接调用系统原生API
            self.glassEffect(glass._interactive ? glass.nativeGlass.interactive() : glass.nativeGlass, in: shape)
        } else {
            // iOS15 ~ iOS25 兼容实现：Material + clipShape形状裁剪
            ZStack {
                self
                    .background(glass.fallbackMaterial)
                    .clipShape(shape)
            }
        }
    }
}

#endif
