import SwiftUI

public enum DesignMotion {
    public static let springTap = Animation.spring(response: 0.3, dampingFraction: 0.75)
    public static let viewerTransition = Animation.timingCurve(0.19, 1.0, 0.22, 1.0, duration: 0.6)
    public static let toastTransition = Animation.timingCurve(0.19, 1.0, 0.22, 1.0, duration: 0.6)
    public static let tabSlide = Animation.spring(response: 0.35, dampingFraction: 0.82)
    public static let reduceMotionCrossfade = Animation.linear(duration: 0.2)
    public static let heartBurstDuration: Double = 0.85
    public static let toastDuration: Double = 3.0
}
