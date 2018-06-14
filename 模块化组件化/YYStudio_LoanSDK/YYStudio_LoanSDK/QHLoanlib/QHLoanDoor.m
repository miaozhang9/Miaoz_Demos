//
//  QHLoanDoor.m
//  LoanLib
//
//  Created by yinxukun on 2016/12/16.
//  Copyright © 2016年 Miaoz. All rights reserved.
//

#import "QHLoanDoor.h"

#import "QHViewController.h"
#import "QHInterceptProtocol.h"
#import "QHLoanDoorBundle.h"
#import "UIColor+QH.h"
#import "QHNavigationbarPlugin.h"
#import "QH.h"
#import "QHNineBoxViewController.h"
#import "QHScanResultViewController.h"
#import "QHCameraPlugin.h"
#import "QHFetchCardViewController.h"
#import "UIImage+QH.h"
#import "NSURLProtocol+WebKitSupport.h"
#import "UIFont+QH.h"
@interface  QHLoanDoor ()


@property (nonatomic, assign) QHLoanDoorEnvironment environment;
@property (nonatomic, strong) QHViewController *viewController;

/*启动的url*/
@property (nonatomic, copy) NSString *startPage;

@property (nonatomic, copy) NSString *agent;




@property (nonatomic, copy) NSString *barColor;

@property (nonatomic, copy) NSString *barTitleColor;



@property (nonatomic, copy) NSString *backBtnTitle;

@property (nonatomic, copy) NSString *backBtnTitleColor;

@property (nonatomic, strong) UIImage *backBtnImage;

@property (nonatomic, weak)id <QHBasicProtocol> basicDelegate;

@property (nonatomic, weak)id <QHCommandDelegate> qhcommandDelegate;
@property (nonatomic, strong)QHInvokedUrlCommand *qhinvokedUrlCommand;



@end

@implementation QHLoanDoor

static QHLoanDoor *door;

+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        door = [[self alloc] init];
    });
    return door;
}

- (instancetype)init{
    if (self = [super init]) {
        self.faceCheckDelegate = [QHFaceCheckDelegate shareDelegate];
    }
    return self;
}

- (QHLoanDoor *(^)(NSDictionary *))setDataInfo
{
    QHLoanDoor * (^callBlock)() = ^(NSDictionary *dataDic) {
        self.dataInfo = dataDic;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSString *))setBarColor
{
    QHLoanDoor * (^callBlock)() = ^(NSString *barColor) {
        self.barColor = barColor;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSString *))setBarTitleColor
{
    QHLoanDoor * (^callBlock)() = ^(NSString *barTitleColor) {
        self.barTitleColor = barTitleColor;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSInteger ))setBarTitleFontSize
{
    QHLoanDoor * (^callBlock)() = ^(NSInteger barTitleFontSize) {
        self.barTitleFontSize = barTitleFontSize;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSString *))setBackBtnTitle
{
    QHLoanDoor * (^callBlock)() = ^(NSString *backBtnTitle) {
        self.backBtnTitle = backBtnTitle;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSString *))setBackBtnTitleColor
{
    QHLoanDoor * (^callBlock)() = ^(NSString *backBtnTitleColor) {
        self.backBtnTitleColor = backBtnTitleColor;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(UIImage *))setBackBtnImage
{
    QHLoanDoor * (^callBlock)() = ^(UIImage *backBtnImage) {
        self.backBtnImage = backBtnImage;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSString *))setStartPageUrl
{
    QHLoanDoor * (^callBlock)() = ^(NSString *startPageUrl) {
        self.startPage = startPageUrl;
        return self;
    };
    return callBlock;
}

- (QHLoanDoor *(^)(NSString *))setAgent
{
    QHLoanDoor * (^callBlock)() = ^(NSString *userAgent) {
        self.agent = userAgent;
        return self;
    };
    return callBlock;
}


- (QHLoanDoor *(^)(QHCoreWebViewEnum ))setCoreWebView {
    QHLoanDoor * (^callBlock)(QHCoreWebViewEnum cc) = ^(QHCoreWebViewEnum coreWebViewEnum) {
        self.coreWebViewEnum = coreWebViewEnum;
      
        return self;
    };
    return callBlock;
    
}

- (QHLoanDoor *(^)(id))setBasicDelegate
{
    QHLoanDoor * (^callBlock)() = ^(id <QHBasicProtocol> basicDelegate) {
        self.basicDelegate = basicDelegate;
        return self;
    };
    return callBlock;
}


-(QHLoanDoor *(^)())start
{
    QHLoanDoor * (^callBlock)() = ^() {

        if (self.coreWebViewEnum != QHCoreWebView_WKWebView && self.coreWebViewEnum != QHCoreWebView_UIWebView) {
            //default QHCoreWebView_UIWebView
            self.coreWebViewEnum = QHCoreWebView_UIWebView ;
        }
        [self registerQHLoanSDKURLProtocol];
 
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        if (!window) {
            NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
            if (_callBackBlcok) {
                self.callBackBlcok(NO, error);
            }
            return self;
        }
        UIViewController *rootCtrl = window.rootViewController;
        if (!rootCtrl) {
            NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
            if (_callBackBlcok) {
                self.callBackBlcok(NO, error);
            }
            return self;
        }
       
        QHViewController *viewController = [[QHViewController alloc] init];
        viewController.superController = rootCtrl;
        self.viewController = viewController;
        viewController.startPage = self.startPage && self.startPage.length > 0 ? self.startPage : nil;
        viewController.baseUserAgent = self.agent ? self.agent : @"ToCred";
        if (self.basicDelegate) {
            viewController.basicDelegate =  self.basicDelegate ;
        }
        
        
        [viewController view];
        viewController.navigationController.navigationBar.translucent = NO;
//        [viewController setAutomaticallyAdjustsScrollViewInsets:NO];
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
       
        // self.viewController.title = @"支持插件列表";
       //push
//        [(UINavigationController*)rootCtrl pushViewController:viewController animated:Yes];
        //present
        [rootCtrl presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:^{
            if (_callBackBlcok) {
                self.callBackBlcok(YES, nil);
            }
            
        }];
        
        self.viewController.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor qh_colorWithHexString:self.barTitleColor?self.barTitleColor:@"#000000"],NSFontAttributeName:[UIFont pingFangSCRegularWithSize:self.barTitleFontSize?self.barTitleFontSize:17]};
        [self.viewController.navigationController.navigationBar setBackgroundColor:[UIColor qh_colorWithHexString:self.barColor?self.barColor:@"#FFFFFF"]];
        self.viewController.navigationController.navigationBar.barTintColor = [UIColor qh_colorWithHexString:self.barColor?self.barColor:@"#FFFFFF"];
        
        [self.viewController.backBtn setTitle:self.backBtnTitle?self.backBtnTitle:@"返回" forState:UIControlStateNormal];
        self.viewController.backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        UIColor *backBtnTitleColor = [UIColor qh_colorWithHexString:self.backBtnTitleColor?self.backBtnTitleColor:@"#000000"];
        [self.viewController.backBtn setTitleColor:backBtnTitleColor forState:UIControlStateNormal];
        
        UIImage * bImage = [UIImage imageNamed:@"BarArrowLeftGray" inBundle:[QHLoanDoorBundle bundle] compatibleWithTraitCollection:nil];
        
        [self.viewController.backBtn setImage:self.backBtnImage? self.backBtnImage:bImage forState: UIControlStateNormal];
        self.viewController.backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 12);

        return self;
    };
    
    return callBlock;
}

- (void)invokCardCamera:(CGFloat)photoSize arg1:(NSString *)arg1 agr2:(NSString *)arg2 borderColor:(NSString *)borderColor takePhotoImageB64:(NSString *)takePhotoImageB64 viewController:(UIViewController *)vc completeBlock:(void(^)(UIImage *img, NSDictionary *errorInfo))completeBlock {
    QHCameraPlugin *cameraPlugin = [[QHCameraPlugin alloc] init];
    //        self.environment = environment;
    //        "apiKey": "xiaoJinTong",
    //        "scenarioId": "997",
    //    partenrcode:” riskrepor”
   QHFetchCardViewController *fetchCardCtrl = [cameraPlugin invokCardCamera:photoSize arg1:arg1 agr2:arg2 borderColor:borderColor takePhotoImageB64:takePhotoImageB64  viewController:vc];
    [fetchCardCtrl setCameraCompleteAction:^(UIImage *img, NSDictionary *errorInfo) {
        if (completeBlock) {
           
            completeBlock([img qh_toDiskSize:photoSize], errorInfo);
        }
        
    }];
}

-(void)registerQHLoanSDKURLProtocol{
    if (self.coreWebViewEnum == QHCoreWebView_WKWebView) {
        for (NSString* scheme in @[@"http", @"https", @"file"]) {
//            ftp://，http://，https://，file:///，data://
            [NSURLProtocol wk_registerScheme:scheme];
            
        }
    }
    [NSURLProtocol registerClass:[QHInterceptProtocol class]];
}

-(void)unRegisterQHLoanSDKURLProtocol{
    if ([QHLoanDoor share].coreWebViewEnum == QHCoreWebView_WKWebView) {
        for (NSString* scheme in @[@"http", @"https", @"file"]) {
            [NSURLProtocol wk_unregisterScheme:scheme];
        }
    }
    [NSURLProtocol unregisterClass:[QHInterceptProtocol class]];
}


- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    [self.viewController interfaceOrientation:orientation];
}

- (void)forceExecuteInterfaceOrientation:(UIInterfaceOrientation)orientation {
     [self.viewController forceExecuteInterfaceOrientation:orientation];
}

- (void)closeAllPages:(void(^)(void))completion  {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewController.presentingViewController)
        {
            [self.viewController dismissViewControllerAnimated:YES completion:^{
                if (completion) {
                    completion();
                }
            }];
        }
        else
        {
            [self.viewController.navigationController popToRootViewControllerAnimated:YES];
            if (completion) {
                completion();
            }
        }
    });
}


- (void)getCommandDelegate:(id)qhcommandDelegate  InvokedUrlCommand:(NSObject *)qhinvokedUrlCommand {
    self.qhcommandDelegate = qhcommandDelegate;
    self.qhinvokedUrlCommand = (QHInvokedUrlCommand *)qhinvokedUrlCommand;
}

- (void)sendCallBackPluginResultDictionary:(NSDictionary *)resultDictionary resultStatus:(BOOL)isSuccess {
    
    if (isSuccess) {
        QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsDictionary:resultDictionary];
        [self.qhcommandDelegate sendPluginResult:result callbackId:self.qhinvokedUrlCommand.callbackId];
    } else {
        QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:resultDictionary];
        [self.qhcommandDelegate sendPluginResult:result callbackId:self.qhinvokedUrlCommand.callbackId];
    }
}


- (void)launchDoor:(NSDictionary *)paras
          dataInfo:(NSDictionary *)dataInfo
             agent:(NSString *)agent
      startPageUrl:(NSString *)startPage
       environment:(QHLoanDoorEnvironment)environment
      successBlock:(void(^)())successBlock
         failBlock:(void(^)(NSError *))failBlock{

    [self registerQHLoanSDKURLProtocol];

    self.environment = environment;

    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if (!window) {
        NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
        if (failBlock) {
            failBlock(error);
        }
        return;
    }
    UIViewController *rootCtrl = window.rootViewController;
    if (!rootCtrl) {
        NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
        if (failBlock) {
            failBlock(error);
        }
        return;
    }
    
    self.dataInfo = dataInfo;
    
    QHViewController *viewController = [[QHViewController alloc] init];
    _viewController = viewController;
    viewController.startPage = startPage ? startPage : nil;
    if (agent) {
         viewController.baseUserAgent = agent;
    } else {
        viewController.baseUserAgent = @"ToCred";
    }
   
    [viewController view];
    viewController.navigationController.navigationBar.translucent = NO;
    // self.viewController.title = @"支持插件列表";
    [rootCtrl presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:^{
        
        if (successBlock) {
            successBlock();
        }
    }];
   
    if (paras) {
         [self setPageUI:paras];
    }
   
    
}

-(void)setPageUI:(NSDictionary *)paras {
    _viewController.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor qh_colorWithHexString:paras[@"BarTitleColor"]]};
    _viewController.navigationController.navigationBar.barTintColor = [UIColor qh_colorWithHexString:paras[@"BarColor"]];
}

- (void)launchScanLink:(NSDictionary *)paras
                 title:(NSString *)title
           environment:(QHLoanDoorEnvironment)environment
          successBlock:(void(^)())successBlock
             failBlock:(void(^)(NSError *error))failBlock{
    
   [self registerQHLoanSDKURLProtocol];
    
    self.environment = environment;
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if (!window) {
        NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
        if (failBlock) {
            failBlock(error);
        }
        return;
    }
    UIViewController *rootCtrl = window.rootViewController;
    if (!rootCtrl) {
        NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
        if (failBlock) {
            failBlock(error);
        }
        return;
    }
    QHNineBoxViewController *viewController = [[QHNineBoxViewController alloc] init];
    viewController.titleStr = title;
    [viewController view];
    viewController.navigationController.navigationBar.translucent = NO;
    [rootCtrl presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:^{
        
        if (successBlock) {
            successBlock();
        }
    }];
//    [self setPageUI:paras];
}

- (void)launchScanResult:(NSDictionary *)paras
           environment:(QHLoanDoorEnvironment)environment
          successBlock:(void(^)())successBlock
             failBlock:(void(^)(NSError *error))failBlock{
    
    [self registerQHLoanSDKURLProtocol];
    
    self.environment = environment;
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if (!window) {
        NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
        if (failBlock) {
            failBlock(error);
        }
        return;
    }
    UIViewController *rootCtrl = window.rootViewController;
    if (!rootCtrl) {
        NSError *error = [NSError errorWithDomain:@"no key window" code:0 userInfo:@{}];
        if (failBlock) {
            failBlock(error);
        }
        return;
    }
    QHScanResultViewController *viewController = [[QHScanResultViewController alloc] init];
    [viewController view];
    viewController.navigationController.navigationBar.translucent = NO;
    [rootCtrl presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:^{
        
        if (successBlock) {
            successBlock();
        }
    }];
//    [self setPageUI:paras];
}


/****
/**
 *
 *  version 版本号
 *
 */
//+ (NSString *)version;
/**
 *
 *  启动SDK
 *
 *  @param  paras  启动参数实体
 *  @param  agent  设置agent标示
 *  @param  environment 环境配置
 *  @param  startPage h5url
 *  @param  successBlock 启动成功回调
 *  @param  failBlock    启动失败回调
 *

- (void)launchDoor:(NSDictionary *)paras
          dataInfo:(NSDictionary *)dataInfo
             agent:(NSString *)agent
      startPageUrl:(NSString *)startPage
       environment:(QHLoanDoorEnvironment)environment
      successBlock:(void(^)())successBlock
         failBlock:(void(^)(NSError *))failBlock;
 */

/**
 启动SDK
 
 @param paras 启动参数实体
 @param title 九宫格页面title
 @param environment 环境配置
 @param successBlock 启动成功回调
 @param failBlock 启动失败回调
 
- (void)launchScanLink:(NSDictionary *)paras
                 title:(NSString *)title
           environment:(QHLoanDoorEnvironment)environment
          successBlock:(void(^)())successBlock
             failBlock:(void(^)(NSError *error))failBlock;
 */

/**
 启动SDK
 
 @param paras 启动参数实体
 @param environment 环境配置
 @param successBlock 启动成功回调
 @param failBlock 启动失败回调

- (void)launchScanResult:(NSDictionary *)paras
             environment:(QHLoanDoorEnvironment)environment
            successBlock:(void(^)())successBlock
               failBlock:(void(^)(NSError *error))failBlock;

 */
@end

