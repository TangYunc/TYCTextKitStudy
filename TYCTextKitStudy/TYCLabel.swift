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
 2.使用正则表达式过滤 URL， 设置URL的特殊显示
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //1.获取用户的点击的位置
        guard let location = touches.first?.location(in: self) else {
            return
        }
        print("\(location)")
        //2.获取当前点中字符的索引
        let idx = layoutManager.glyphIndex(for: location, in: textContainer)
        print("点我了 \(idx)")
        for r in urlRanges ?? [] {
            if NSLocationInRange(idx, r) {
                print("需要高亮")
                //修改文本的字体属性
                textStorage.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], range: r)
                //如果需要重绘，需要调用一个函数setNeedsDisplay，但是不是drawRect
                setNeedsDisplay()
            } else {
                print("没戳中")
            }
        }
    }
    //MARK: - 绘制文本
    /**
        在iOS中绘制工作是类似于油画似的，后绘制的内容，会把之前会知道的内容覆盖
     */
    override func drawText(in rect: CGRect) {
        
        let range = NSRange(location: 0, length: textStorage.length)
        //绘制字形
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
        // Glyphs 字形
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
//        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
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
        
        //0. 开启用户交互
        isUserInteractionEnabled = true
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
        print(urlRanges)
        //便利范围数组，设置URL文字的属性
        for r in urlRanges ?? [] {
            textStorage.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red, NSAttributedStringKey.backgroundColor: UIColor.init(white: 0.9, alpha: 1.0)], range: r)
        }
    }
}

// MARK: - 正则表达式函数
private extension TYCLabel {
    /// 返回 textStorage 中的 URL range数组
    var urlRanges: [NSRange]? {
        
        //1.正则表达式
        let parttern = "[a-zA-Z]*://[a-zA-Z0-9/\\.]*"
        guard let regx = try? NSRegularExpression(pattern: parttern, options: []) else {
            return nil
        }
        //2.多重匹配
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        //3. 遍历数组，生成range的数组
        var ranges = [NSRange]()
        
        for m in matches {
            ranges.append(m.range(at: 0))
        }
        return ranges
    }
    
}
