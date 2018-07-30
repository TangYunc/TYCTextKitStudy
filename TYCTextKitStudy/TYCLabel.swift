//
//  TYCLabel.swift
//  TYCTextKitStudy
//
//  Created by tangyunchuan on 2018/7/30.
//  Copyright © 2018年 tangyunchuan. All rights reserved.
//

import UIKit

/**
 1.使用textKit 接管 Label 的底层实现 - '绘制' textStorage 的文本内容
 2.使用正则表达式过滤 URL
 3.交互
 
 - UILabel 默认不能实现垂直顶部对齐, 使用TextKit
 */
class TYCLabel: UILabel {

    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareTextSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareTextSystem()
    }
    
    //绘制文本
    override func drawText(in rect: CGRect) {
        
        let range = NSRange(location: 0, length: textStorage.length)
        // Glyphs 字形
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //指定绘制文本的区域
        textContainer.size = bounds.size
    }
    //MARK: TextKit 的核心对象
    /// 属性文本存储
    private lazy var textStorage = NSTextStorage()
    /// 负责文本的‘字形’布局
    private lazy var layoutManager = NSLayoutManager()
    /// 设定文本的绘制范围
    private lazy var textContainer = NSTextContainer()

}

// MARK: - 设置TextKit 核心对象
private extension TYCLabel {
    /// 准备文本系统
    func prepareTextSystem()  {
        //1. 准备文本内容
        prepareTextContent()
        //2. 设置对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    /// 准备文本内容 - 使用textStorage接管 label 的内容
    func prepareTextContent() {
        
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        }else if let text = text {
            textStorage.setAttributedString(NSAttributedString(string: text))
        }else {
            textStorage.setAttributedString(NSAttributedString(string: ""))
        }
    }
}
