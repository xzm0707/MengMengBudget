//
//  Extensions.swift
//  MengMengBudget
//
//  Created by 徐泽敏 on 2025/3/6.
//

import SwiftUI

// 视图扩展
extension View {
    // 自定义圆角
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // 弹性按钮效果
    func springyButton(scale: CGFloat = 0.9) -> some View {
        buttonStyle(SpringyButtonStyle(scale: scale))
    }
}

// 圆角形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// 弹性按钮样式
struct SpringyButtonStyle: ButtonStyle {
    let scale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
