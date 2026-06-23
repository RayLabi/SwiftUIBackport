#if canImport(SwiftUI)
import SwiftUI

// MARK: - 给 Animation 扩展兼容版 timingCurve 方法
extension Animation {
    /// 兼容版 timingCurve：自动适配 iOS 17+ / iOS < 17
    /// - Parameters:
    ///   - curve: 兼容版 UnitCurve 枚举
    ///   - duration: 动画时长，默认 0.35 秒（贴近系统默认值）
    /// - Returns: 适配后的 Animation 实例
    public static func timingCurveBackport(
        _ curve: UnitCurveBackport,
        duration: TimeInterval = 0.35
    ) -> Animation {
        // iOS 17+：直接使用系统原生的 UnitCurve 和 timingCurve 重载
        if #available(iOS 17.0, *) {
            // 把兼容版枚举映射为系统原生 UnitCurve
            let nativeUnitCurve: UnitCurve = {
                switch curve {
                case .easeInOut: return .easeInOut
                case .easeIn: return .easeIn
                case .easeOut: return .easeOut
                case .circularEaseIn: return .circularEaseIn
                case .circularEaseOut: return .circularEaseOut
                case .circularEaseInOut: return .circularEaseInOut
                case .linear: return .linear
                }
            }()
            // 调用系统原生的 timingCurve(UnitCurve, duration:)
            return .timingCurve(nativeUnitCurve, duration: duration)
        } else {
            // iOS < 17：手动映射为 timingCurve 的贝塞尔曲线参数
            switch curve {
            case .easeInOut:
                return .easeInOut(duration: duration) // 系统已有封装
            case .easeIn:
                return .easeIn(duration: duration)    // 系统已有封装
            case .easeOut:
                return .easeOut(duration: duration)   // 系统已有封装
            case .circularEaseIn:
                // 传入圆弧曲线缓入的贝塞尔参数
                return .timingCurve(0.55, 0, 1, 0.45, duration: duration)
            case .circularEaseOut:
                // 传入圆弧曲线缓出的贝塞尔参数
                return .timingCurve(0, 0.55, 0.45, 1, duration: duration)
            case .circularEaseInOut:
                // 传入圆弧曲线缓入缓出的贝塞尔参数
                return .timingCurve(0.785, 0.135, 0.15, 0.86, duration: duration)
            case .linear:
                return .linear(duration: duration)    // 系统已有封装
            }
        }
    }
}

#endif
