//
//  ConfigurationBeaconViewController.m
//  iBeaconDemo
//
//  Created by Zhang on 2019/4/23.
//  Copyright © 2019 LaiYoung_. All rights reserved.
//

#import "ConfigurationBeaconViewController.h"
#import "DiscoverBeaconViewController.h"

@interface ConfigurationBeaconViewController ()

@property (weak, nonatomic) IBOutlet UITextField *uuidText;

@property (weak, nonatomic) IBOutlet UITextField *majorText;

@property (weak, nonatomic) IBOutlet UITextField *minorText;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;


@property (nonatomic, strong) NSMutableArray *equipmentArray;

@end

@implementation ConfigurationBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self textViewShow];
}

- (NSMutableArray *)equipmentArray {
    if (!_equipmentArray) {
        _equipmentArray = [NSMutableArray array];
    }
    return _equipmentArray;
}

- (IBAction)add:(id)sender {
    _tipLabel.text = @"";
    //uudi
    if ([self isStringEmpty:_uuidText.text]) {
        _tipLabel.text = @"请输入 UUID";
        return;
    }
    //major
    if ([self isStringEmpty:_majorText.text]) {
        _tipLabel.text = @"请输入 Major";
        return;
    }
    //minor
    if ([self isStringEmpty:_minorText.text]) {
        _tipLabel.text = @"请输入 Minor";
        return;
    }
    
    //
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"UUID"] = _uuidText.text;
    dic[@"Major"] = _majorText.text;
    dic[@"Minor"] = _minorText.text;
    [self.equipmentArray addObject:dic];
    //
    [self textViewShow];
    //
    [self endEditing];
}

- (IBAction)remove:(id)sender {
    //
    [self.equipmentArray removeAllObjects];
    //
    [self textViewShow];
    //
    [self endEditing];
}

- (IBAction)discover:(id)sender {
    //
    _tipLabel.text = @"";
    //
    if (self.equipmentArray.count) {
        DiscoverBeaconViewController *vc = [[DiscoverBeaconViewController alloc] init];
        vc.title = @"发现 Beacon";
        vc.equipmentArray = self.equipmentArray.copy;
        vc.tag = DiscoverBeacon;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        _tipLabel.text = @"请输入设备";
    }
    //
    [self endEditing];
}

- (BOOL)isStringEmpty:(NSString *)str {
    
    if (!str) {
        return true;
    }else if ([str isKindOfClass:[NSNull class]]){
        return true;
    }else if ([str isEqualToString:@"null"]){
        return true;
    }else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing];
}

- (void)endEditing {
    [self.view endEditing:YES];
}

- (void)textViewShow {
    NSString *str = @"当前添加设备：\n";
    if (self.equipmentArray.count) {
        for (NSDictionary *dic in self.equipmentArray) {
            NSString *dicStr = [NSString stringWithFormat:@"UUID:%@ \nMajor:%@ \nMinor:%@ \n--------------------\n",dic[@"UUID"], dic[@"Major"], dic[@"Minor"]];
            str = [str stringByAppendingString:dicStr];
        }
        _textView.text = str;
    } else {
        _textView.text = str;
    }
}

@end
