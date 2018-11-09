//
//  LWIdCardCheckTool.m
//  HaoYuClient
//
//  Created by 刘文强 on 2018/11/7.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "LWIdCardCheckTool.h"
/**
 json文件路径
 */
static NSString * const CIYTDATA_JSON_PATH = @"CitysCodeJson";

/**
 台湾正则
 */
static NSString * TAIWAN_ZE =  @"^[a-zA-Z][0-9]{9}$";

/**
 澳门正则
 */
static NSString * AOMEN_ZE =  @"^[1|5|7][0-9]{6}\\(?[0-9A-Z]\\)?$";

/**
 香港正则
 */
static NSString * XIANGGANG_ZE =  @"^[a-zA-Z]{1,2}[0-9]{6}\\(?[0-9A]\\)?$";

/**
 * 中国公民身份证号码最小长度。
 */
static int const CHINA_ID_MIN_LENGTH = 15;

/**
 * 中国公民身份证号码最大长度。
 */
static int const CHINA_ID_MAX_LENGTH = 18;

/**
 * 最低年限
 */
static int MIN = 1930;

@interface LWIdCardCheckTool ()
{
    /**
     * 省、直辖市代码表
     */
    NSArray * cityCode;
    /**
     * 每位加权因子
     */
    NSArray * power;
    /**
     * 第18位校检码
     */
    NSArray * verifyCode;
    /**
     大陆城市code
     */
    NSDictionary * cityCodes;
    /**
     * 台湾身份首字母对应数字
     */
    NSDictionary * twFirstCode;
    /**
     * 香港身份首字母对应数字
     */
    NSDictionary * hkFirstCode;
}
@end

@implementation LWIdCardCheckTool

/**
 * 验证身份证是否合法
 */
+ (BOOL)validateCard:(NSString *)idCard
{
    LWIdCardCheckTool *instance = [LWIdCardCheckTool new];
    [instance config];
    NSString * card = [idCard stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([instance validateIdCard18:card]) {
        return true;
    }
    if ([instance validateIdCard15:card]) {
        return true;
    }
    NSArray * cardval = [instance validateIdCard10:card];
    if (cardval != nil) {
        if ([@"true" isEqualToString:cardval[2]]) {
            return true;
        }
    }
    return false;
}

/**
 * 验证18位身份编码是否合法
 *
 * @param idCard 身份编码
 * @return 是否合法
 */
- (BOOL)validateIdCard18:(NSString *)idCard
{
    BOOL bTrue = false;
    if (idCard.length == CHINA_ID_MAX_LENGTH) {
        // 前17位
        NSString *code17 = [idCard substringWithRange:NSMakeRange(0, 17)];
        // 第18位
        NSString *code18 = [idCard substringWithRange:NSMakeRange(17, 1)];
        if ([self isNum:code17]) {
            NSArray *code17Arr = [self stringToArrayWithStrig:code17];
            if (code17Arr != nil && code17Arr.count != 0) {
                NSInteger iSum17 = [self getPowerSum:code17Arr];
                // 获取校验位
                NSString *val =  [self getCheckCode18:iSum17];
                if (val.length > 0) {
                    if ([val compare:code18 options:NSCaseInsensitiveSearch | NSNumericSearch] == NSOrderedSame) {
                        bTrue = true;
                    }
                }
            }
        }
    }
    return bTrue;
}

/**
 字符串转数组
 */
- (NSArray *)stringToArrayWithStrig:(NSString *)str
{
    NSMutableArray *muArr = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < str.length; i ++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *strTemp = [str substringWithRange:range];
        [muArr addObject:strTemp];
    }
    return muArr;
}

/**
 * 将身份证的每位和对应位的加权因子相乘之后，再得到和值
 *
 * @param iArr
 * @return 身份证编码。
 */
- (NSInteger)getPowerSum:(NSArray *)iArr
{
    NSInteger iSum = 0;
    if (power.count == iArr.count) {
        for (int i = 0; i < iArr.count; i++) {
            for (int j = 0; j < power.count; j++) {
                if (i == j) {
                    iSum = iSum + [iArr[i] integerValue] * [power[j] integerValue];
                }
            }
        }
    }
    return iSum;
}

/**
 * 将power和值与11取模获得余数进行校验码判断
 *
 * @param iSum
 * @return 校验位
 */
- (NSString *)getCheckCode18:(NSInteger)iSum
{
    NSString * sCode = @"";
    switch (iSum % 11) {
        case 10:
            sCode = @"2";
            break;
        case 9:
            sCode = @"3";
            break;
        case 8:
            sCode = @"4";
            break;
        case 7:
            sCode = @"5";
            break;
        case 6:
            sCode = @"6";
            break;
        case 5:
            sCode = @"7";
            break;
        case 4:
            sCode = @"8";
            break;
        case 3:
            sCode = @"9";
            break;
        case 2:
            sCode = @"x";
            break;
        case 1:
            sCode = @"0";
            break;
        case 0:
            sCode = @"1";
            break;
    }
    return sCode;
}

/**
 * 验证15位身份编码是否合法
 *412702 19990506
 * @param idCard 身份编码
 * @return 是否合法
 */
- (BOOL)validateIdCard15:(NSString *)idCard
{
    if (idCard.length != CHINA_ID_MIN_LENGTH) {
        return false;
    }
    if ([self isNum:idCard]) {
        NSString * proCode = [idCard substringWithRange:NSMakeRange(0, 2)];
        if ([cityCodes objectForKey:proCode] == nil) {
            return false;
        }
        NSString *birthCode = [idCard substringWithRange:NSMakeRange(6, 8)];
        NSString *iYear = [birthCode substringWithRange:NSMakeRange(0, 4)];
        NSString *iMonth = [birthCode substringWithRange:NSMakeRange(4, 2)];
        NSString *iDate = [birthCode substringWithRange:NSMakeRange(6, 2)];
        if(![self valiDate:[iYear integerValue] iMonth:[iMonth integerValue] iDate:[iDate integerValue]]){
            return false;
        }
    } else {
        return false;
    }
     return true;
}

/**
 * 验证10位身份编码是否合法
 *
 * @param idCard 身份编码
 * @return 身份证信息数组
 * <p>
 * [0] - 台湾、澳门、香港 [1] - 性别(男M,女F,未知N) [2] - 是否合法(合法true,不合法false)
 * 若不是身份证件号码则返回null
 * </p>
 */
- (NSArray *)validateIdCard10:(NSString *)idCard
{
    NSMutableArray *info = [[NSMutableArray alloc] initWithCapacity:2];
    NSArray *charaArr = @[@"[",@"(",@")",@"]"];
    for (NSString *str in charaArr) {
        [idCard stringByReplacingOccurrencesOfString:str withString:@""];
    }
    if (idCard.length != 8 && idCard.length != 9 && idCard.length != 10) {
        return nil;
    }
    if ([self valiLocationWithString:idCard ze:TAIWAN_ZE]) { // 台湾
        info[0] = @"台湾";
        NSLog(@"**********台湾");
        NSString *char2 = [idCard substringWithRange:NSMakeRange(1, 1)];
        if ([char2 isEqualToString:@"1"]) {
            info[1] = @"M";
        } else if ([char2 isEqualToString:@"2"]) {
            info[1] = @"F";
        } else {
            info[1] = @"N";
            info[2] = @"false";
            return info;
        }
        info[2] = [self validateTWCard:idCard] ? @"true" : @"false";
    } else if ([self valiLocationWithString:idCard ze:AOMEN_ZE]) { // 澳门
        info[0] = @"澳门";
        info[1] = @"N";
    } else if ([self valiLocationWithString:idCard ze:XIANGGANG_ZE]) { // 香港
        info[0] = @"香港";
        info[1] = @"N";
        info[2] = [self validateHKCard:idCard] ? @"true" : @"false";
    } else {
        return nil;
    }
    return info;
}

/**
 *  根据正则表达式验证当前字符串
 *
 *  @param regularExpression 正则表达式
 *  @return 是否符合标准
 */
- (BOOL)ex_checkStringWithRegularExpression:(NSString *)regularExpression
{
    NSPredicate *pred                           = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regularExpression];
    return [pred evaluateWithObject:self];
}

- (BOOL)valiLocationWithString:(NSString *)string ze:(NSString *)ze
{
    NSPredicate *pred                           = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ze];
    return [pred evaluateWithObject:string];
}

/**
 * 验证台湾身份证号码
 *
 * @param idCard 身份证号码
 * @return 验证码是否符合
 */
- (BOOL)validateTWCard:(NSString *)idCard {
    NSString *start = [[idCard substringWithRange:NSMakeRange(0, 1)] uppercaseString];
    NSString *mid = [idCard substringWithRange:NSMakeRange(1, 8)];
    NSString *end = [idCard substringWithRange:NSMakeRange(9, 1)];
    NSInteger iStart = [[twFirstCode objectForKey:start] integerValue];
    NSInteger sum = iStart / 10 + (iStart % 10) * 9;
    NSInteger iflag = 8;
    for (int i = 0; i <mid.length; i++) {
        sum = sum + [[mid substringWithRange:NSMakeRange(i, 1)] integerValue] *iflag;
        iflag--;
    }
    return (sum % 10 == 0 ? 0 : (10 - sum % 10)) == [end integerValue];
}

/**
 * 验证香港身份证号码(存在Bug，部份特殊身份证无法检查)
 * <p>
 * 身份证前2位为英文字符，如果只出现一个英文字符则表示第一位是空格，对应数字58 前2位英文字符A-Z分别对应数字10-35
 * 最后一位校验码为0-9的数字加上字符"A"，"A"代表10
 * </p>
 * <p>
 * 将身份证号码全部转换为数字，分别对应乘9-1相加的总和，整除11则证件号码有效
 * </p>
 *
 * @param idCard 身份证号码
 * @return 验证码是否符合
 */
- (BOOL)validateHKCard:(NSString *)idCard {
    NSInteger sum = 0;
    if (idCard.length == 9) {
        NSString *card1 = [idCard substringWithRange:NSMakeRange(0, 1)];
        NSString *card2 = [idCard substringWithRange:NSMakeRange(1, 1)];
        sum = ([card1 integerValue] - 55)*9 + ([card2 integerValue] - 55) * 8;
        idCard = [idCard substringWithRange:NSMakeRange(1, 8)];
    } else {
        NSString *card1 = [idCard substringWithRange:NSMakeRange(0, 1)];
        sum = 522 + ([card1 integerValue] - 55) * 8;
    }
    NSString *mid =  [idCard substringWithRange:NSMakeRange(1, 6)];
    NSString *end = [idCard substringWithRange:NSMakeRange(7, 1)];
    NSInteger iflag = 7;
    for (int i = 0; i <mid.length; i++) {
        sum = sum + [[mid substringWithRange:NSMakeRange(i, 1)] integerValue] * iflag;
        iflag--;
    }
    if ([@"A" isEqualToString:[end uppercaseString]]) {
        sum = sum + 10;
    } else {
        sum = sum + [end integerValue];
    }
    return (sum % 11 == 0);
}

/**
 * 验证小于当前日期 是否有效
 *
 * @param iYear  待验证日期(年)
 * @param iMonth 待验证日期(月 1-12)
 * @param iDate  待验证日期(日)
 * @return 是否有效
 */
- (BOOL)valiDate:(NSInteger)iYear iMonth:(NSInteger)iMonth iDate:(NSInteger)iDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    NSInteger year=[[formatter stringFromDate:date] integerValue];
    NSInteger datePerMonth;
    if (iYear < MIN || iYear >= year) {
        return false;
    }
    if (iMonth < 1 || iMonth > 12) {
        return false;
    }
    switch (iMonth) {
        case 4:
        case 6:
        case 9:
        case 11:
            datePerMonth = 30;
            break;
        case 2:
            {
                BOOL dm = ((iYear % 4 == 0 && iYear % 100 != 0) || (iYear % 400 == 0))
            && (iYear > MIN && iYear < year);
            datePerMonth = dm ? 29 : 28;
                }
            break;
        default:
            datePerMonth = 31;
    }
    return (iDate >= 1) && (iDate <= datePerMonth);
}

/**
 * 数字验证
 *
 * @param number
 * @return 提取的数字。
 */
- (BOOL)isNum:(NSString *)number {
    BOOL res = true;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = false;
            break;
        }
        i++;
    }
    return res;
}

- (void)config
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:CIYTDATA_JSON_PATH ofType:@"json"];
    if (!jsonPath) {
        return;
    }
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *info = result[@"info"];
    
    NSLog(@"\n\n**********************json_info:%@",info);
    /**
     大陆城市code
     */
    cityCodes = info[@"citys"];
    /**
     * 台湾身份首字母对应数字
     */
    twFirstCode = info[@"tw"];
    /**
     * 台湾身份首字母对应数字
     */
    hkFirstCode = info[@"hk"];
    /**
     * 省、直辖市代码表
     */
    cityCode = info[@"cityCode"];
    /**
     * 每位加权因子
     */
    power = info[@"power"];
    /**
     * 第18位校检码
     */
    verifyCode = info[@"verifyCode"];
}

@end
