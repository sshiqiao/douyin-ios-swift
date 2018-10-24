//
//  SystemMessageCell.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class SystemMessageCell:UITableViewCell {
    
    
    var textView:UITextView = UITextView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorClear
        initSubViews()
    }
    
    func initSubViews() {
        textView.textColor = SystemMessageCell.attributes()[.foregroundColor] as? UIColor
        textView.font = SystemMessageCell.attributes()[.font] as? UIFont
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = ColorGrayDark
        textView.textContainerInset = UIEdgeInsets.init(top: SYS_MSG_CORNER_RADIUS, left: SYS_MSG_CORNER_RADIUS, bottom: SYS_MSG_CORNER_RADIUS, right: SYS_MSG_CORNER_RADIUS)
        textView.textContainer.lineFragmentPadding = 0
        textView.layer.cornerRadius = SYS_MSG_CORNER_RADIUS
        self.addSubview(textView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let attributedString = NSMutableAttributedString.init(attributedString: textView.attributedText)
        let size = attributedString.multiLineSize(width: MAX_SYS_MSG_WIDTH)
        textView.frame = CGRect.init(x: screenWidth/2 - size.width/2 - SYS_MSG_CORNER_RADIUS, y: COMMON_MSG_PADDING*2, width: size.width + SYS_MSG_CORNER_RADIUS * 2, height: size.height + SYS_MSG_CORNER_RADIUS * 2)
    }
    
    func initData(chat:GroupChat) {
        var attributedString:NSMutableAttributedString = NSMutableAttributedString.init(string: chat.msg_content ?? "")
        attributedString.addAttributes(SystemMessageCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        textView.attributedText = attributedString
    }
    
    static func attributes() -> [NSAttributedString.Key:Any] {
        return [.font: MediumFont, .foregroundColor:ColorGray]
    }
    
    static func cellHeight(chat:GroupChat) -> CGFloat {
        var attributedString = NSMutableAttributedString.init(string: chat.msg_content ?? "")
        attributedString.addAttributes(SystemMessageCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        let size = attributedString.multiLineSize(width: MAX_SYS_MSG_WIDTH)
        return size.height + COMMON_MSG_PADDING * 2 + SYS_MSG_CORNER_RADIUS * 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
