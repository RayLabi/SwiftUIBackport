#if canImport(SwiftUI)

import SwiftUI

/// 兼容版 UnitCurve：复刻 iOS 17+ 的 UnitCurve 枚举
/// 覆盖常用的动画曲线类型，保证多版本API对齐
public enum UnitCurveBackport : Sendable, Hashable {
    case easeInOut      // 缓入缓出（默认）
    case easeIn         // 缓入
    case easeOut        // 缓出
    case circularEaseIn // 圆形缓入
    case circularEaseOut// 圆形缓出
    case circularEaseInOut // 圆形缓入缓出
    case linear         // 线性（匀速）
}

#endif

