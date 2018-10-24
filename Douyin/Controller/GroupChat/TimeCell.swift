//
//  TimeCell.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/9.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

import Foundation

class TimeCell:UITableViewCell {
    
    var textView:UITextView = UITextView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorClear
        initSubViews()
    }
    
    func initSubViews() {
        textView.textColor = TimeCell.attributes()[.foregroundColor] as? UIColor
        textView.font = TimeCell.attributes()[.font] as? UIFont
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = ColorClear
        textView.textContainerInset = UIEdgeInsets.init(top: SYS_MSG_CORNER_RADIUS*2, left: SYS_MSG_CORNER_RADIUS, bottom: 0, right: SYS_MSG_CORNER_RADIUS)
        textView.textContainer.lineFragmentPadding = 0
        self.addSubview(textView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.snp.makeConstraints { make in
            make.centerX.bottom.equalTo(self)
        }
    }
    
    func initData(chat:GroupChat) {
        var attributedString:NSMutableAttributedString = NSMutableAttributedString.init(string: chat.msg_content ?? "")
        attributedString.addAttributes(TimeCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        textView.attributedText = attributedString
    }
    
    static func attributes() -> [NSAttributedString.Key:Any] {
        return [.font: SmallFont, .foregroundColor:ColorGray]
    }
    
    static func cellHeight(chat:GroupChat) -> CGFloat {
        var attributedString = NSMutableAttributedString.init(string: chat.msg_content ?? "")
        attributedString.addAttributes(TimeCell.attributes(), range: NSRange.init(location: 0, length: attributedString.length))
        attributedString = EmotionHelper.stringToEmotion(str: attributedString)
        let size = attributedString.multiLineSize(width: MAX_SYS_MSG_WIDTH)
        return size.height + COMMON_MSG_PADDING * 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
