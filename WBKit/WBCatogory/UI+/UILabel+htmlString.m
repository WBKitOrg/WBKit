//
//  UILabel+htmlString.m
//  WBKit
//
//  Created by wangbo on 2017/11/30.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "UILabel+htmlString.h"
#import "NSString+DecodingXMLEntities.h"
#import "UIColor+WBAdditions.h"
#import <objc/runtime.h>

static char htmlTextKey;
@implementation UILabel (htmlString)

- (void)setHtmlText:(NSString *)htmlText
{
    objc_setAssociatedObject(self, &htmlTextKey, htmlText, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (htmlText.length == 0) {
        self.text = htmlText;
        return;
    }
    
    self.attributedText = [self.class convertHtml:htmlText label:self];
}

- (NSString *)htmlText
{
    return objc_getAssociatedObject(self, &htmlTextKey);
}

+ (NSAttributedString *)convertHtml:(NSString *)html label:(UILabel *)label
{
    if (html.length == 0) {
        return nil;
    }
    
    static NSString *imagePattern = @"<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>";
    static NSRegularExpression *regex = nil;
    if (!regex) {
        regex = [NSRegularExpression regularExpressionWithPattern:imagePattern
                                                          options:NSRegularExpressionCaseInsensitive                                              error:nil];
    }
    
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:html
                                                             options:0
                                                               range:NSMakeRange(0, html.length)];
    if (result && result.count > 0) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        NSUInteger lastPos = 0;
        for (int i = 0; i<result.count; i++) {
            NSTextCheckingResult *res = result[i];
            NSRange imageRange = res.range;
            [self appendTextAttribute:attrString
                               inHtml:html
                              atRange:NSMakeRange(lastPos, imageRange.location-lastPos)
                             forLabel:label];
            if (res.numberOfRanges < 1) {
                lastPos = imageRange.location + imageRange.length;
                continue;
            }
            NSRange urlRange = [res rangeAtIndex:1];
            NSString *urlText = [html substringWithRange:urlRange];
            NSURL *url = [NSURL URLWithString:urlText];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData scale:2];
            if (image) {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = image;
                attachment.bounds = CGRectMake(0, -(image.size.height - label.font.capHeight)/2,
                                               image.size.width, image.size.height);
                [attrString appendAttributedString:
                 [NSAttributedString attributedStringWithAttachment:attachment]];
            }
            lastPos = imageRange.location + imageRange.length;
        }
        
        [self appendTextAttribute:attrString
                           inHtml:html
                          atRange:NSMakeRange(lastPos, html.length-lastPos)
                         forLabel:label];
        return attrString;
    } else {
        NSMutableAttributedString *attrString
        = [[NSMutableAttributedString alloc] init];
        [self appendTextAttribute:attrString
                           inHtml:html
                          atRange:NSMakeRange(0, html.length)
                         forLabel:label];
        return attrString;
    }
}

+ (void)appendTextAttribute:(NSMutableAttributedString *)str
                     inHtml:(NSString *)html
                    atRange:(NSRange)range
                   forLabel:(UILabel *)label
{
    if (range.length <= 0) {
        return;
    }
    
    static NSString *pattern = @"<font[^>]*>([^<]*)</font>";
    static NSRegularExpression *regex = nil;
    if (regex == nil) {
        regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
    }
    
    NSString *subHtml = [html substringWithRange:range];
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:subHtml
                                                             options:0
                                                               range:NSMakeRange(0, subHtml.length)];
    if (!result || result.count == 0) {
        subHtml = [subHtml stringByDecodingXMLEntities];
        NSAttributedString *tmp
        = [[NSAttributedString alloc]
           initWithString:subHtml
           attributes:@{NSForegroundColorAttributeName: label.textColor,
                        NSFontAttributeName: label.font}
           ];
        [str appendAttributedString:tmp];
        return;
    }
    
    NSUInteger lastPos = 0;
    for (int i = 0; i<result.count; i++) {
        NSTextCheckingResult *res = result[i];
        NSRange range = res.range;
        NSString *tag = [subHtml substringWithRange:range];
        if (range.location > lastPos) {
            NSString *plainText = [subHtml substringWithRange:NSMakeRange(lastPos, range.location - lastPos)];
            plainText = [plainText stringByDecodingXMLEntities];
            NSAttributedString *tmp = [[NSAttributedString alloc]
                                       initWithString:plainText
                                       attributes:@{NSForegroundColorAttributeName: label.textColor,
                                                    NSFontAttributeName: label.font}];
            [str appendAttributedString:tmp];
        }
        
        if (res.numberOfRanges > 1) {
            NSRange textRange = [res rangeAtIndex:1];
            [self appendTextAttribute:str
                                  tag:tag
                       plainTextRange:NSMakeRange(textRange.location - range.location,
                                                  textRange.length)
                             forLabel:label];
        }
        
        lastPos = range.location + range.length;
    }
    
    if (lastPos < subHtml.length) {
        NSString *plainText = [subHtml substringWithRange:NSMakeRange(lastPos, subHtml.length - lastPos)];
        plainText = [plainText stringByDecodingXMLEntities];
        NSAttributedString *tmp = [[NSAttributedString alloc]
                                   initWithString:plainText
                                   attributes:@{NSForegroundColorAttributeName: label.textColor,
                                                NSFontAttributeName: label.font}];
        [str appendAttributedString:tmp];
    }
}

+ (void)appendTextAttribute:(NSMutableAttributedString *)str
                        tag:(NSString *)tag
             plainTextRange:(NSRange)range
                   forLabel:(UILabel *)label
{
    UIColor *color = label.textColor;
    UIFont *font = label.font;
    NSString *plainText = [tag substringWithRange:range];
    NSString *tagWithoutText =
    [tag stringByReplacingOccurrencesOfString:plainText
                                   withString:@""
                                      options:NSCaseInsensitiveSearch
                                        range:range];
    
    static NSString *fontSizePattern = @"font-size\\s*=\\s*['\"]\\s*([\\d]+)\\s*px\\s*['\"]";
    static NSRegularExpression *fontSizeRegex = nil;
    if (!fontSizeRegex) {
        fontSizeRegex = [NSRegularExpression regularExpressionWithPattern:fontSizePattern
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:nil];
    }
    NSTextCheckingResult *fontSizeResult
    = [fontSizeRegex firstMatchInString:tagWithoutText
                                options:0
                                  range:NSMakeRange(0, tagWithoutText.length)];
    if (fontSizeResult && fontSizeResult.numberOfRanges > 1) {
        NSRange range = [fontSizeResult rangeAtIndex:1];
        NSString *fontSizeString = [tagWithoutText substringWithRange:range];
        CGFloat size = [fontSizeString doubleValue];
        font = [UIFont fontWithName:label.font.fontName size:size];
    }
    
    
    static NSString *colorPattern = @"color\\s*=[\\s*'\"]+([^'\"]+)['\"]";
    static NSRegularExpression *colorRegex = nil;
    if (!colorRegex) {
        colorRegex = [NSRegularExpression regularExpressionWithPattern:colorPattern
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:nil];
    }
    
    NSTextCheckingResult *colorResult
    = [colorRegex firstMatchInString:tagWithoutText
                             options:0
                               range:NSMakeRange(0, tagWithoutText.length)];
    if (colorResult && colorResult.numberOfRanges > 1) {
        NSRange range = [colorResult rangeAtIndex:1];
        NSString *colorString = [tagWithoutText substringWithRange:range];
        if ([colorString hasPrefix:@"#"]) {
            colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
            colorString = [colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            color = [UIColor colorWithHexString:colorString];
        } else if ([colorString hasPrefix:@"rgb"]) {
            color = [UIColor colorWithRGBString:colorString];
        }
    }
    
    plainText = [plainText stringByDecodingXMLEntities];
    NSAttributedString *attrStr
    = [[NSAttributedString alloc] initWithString:plainText
                                      attributes:@{NSForegroundColorAttributeName: color,
                                                   NSFontAttributeName:font}];
    [str appendAttributedString:attrStr];
}


@end
