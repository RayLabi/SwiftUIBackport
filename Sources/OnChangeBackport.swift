#if canImport(SwiftUI)
import SwiftUI

public extension View {
    /// Backport iOS17 onChange(old, new) 兼容 iOS14+
    @ViewBuilder
    func onChangeBackport<V>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View where V : Equatable {
        if #available(iOS 17.0, *) {
            // 使用原生新版onChange，同时拿到新旧值
            self.onChange(of: value, initial: initial, action)
        } else {
            // 模拟：用State存上一次的值
            self.modifier(OnChangeBackportModifier(value: value, initial: initial, action: action))
        }
    }
}

// 私有Modifier，保存上一次的值
private struct OnChangeBackportModifier<V: Equatable>: ViewModifier {
    let value: V
    let initial: Bool
    let action: (V, V) -> Void
    
    // 缓存上一次的值
    @State private var oldValue: V
    // 标记是否已经执行过 initial 回调
    @State private var hasTriggeredInitial = false

    init(value: V, initial: Bool, action: @escaping (V, V) -> Void) {
        self.value = value
        self.initial = initial
        self.action = action
        self._oldValue = State(initialValue: value)
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // 视图首次出现，执行 initial 回调
                guard initial, !hasTriggeredInitial else { return }
                hasTriggeredInitial = true
                action(oldValue, value)
            }
            .onChange(of: value) { newValue in
                action(oldValue, newValue)
                oldValue = newValue
            }
    }
}
#endif
