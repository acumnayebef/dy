// tweak.mm — меню (только Creators). Читы вшиты патчем в UnityFramework, тумблеров нет.
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <os/log.h>

#pragma mark - Конфиг

static NSString *const kMenuTitle    = @"XANTAPERS";
static NSString *const kAuthorName   = @"By xantapers";
static NSString *const kTGChannel    = @"@xantapers";
static NSString *const kTGHandle     = @"@xantapers";
static NSString *const kTGChannelURL = @"https://t.me/xantapers";
static NSString *const kTGHandleURL  = @"https://t.me/xantapers";

static const CGFloat kPanelW = 320;
static const CGFloat kPanelH = 380;

#pragma mark - Цвета

static UIColor *C_BG(void)      { return [UIColor colorWithRed:0.04 green:0.05 blue:0.12 alpha:0.96]; }
static UIColor *C_PANEL(void)   { return [UIColor colorWithRed:0.07 green:0.09 blue:0.20 alpha:0.98]; }
static UIColor *C_ACCENT(void)  { return [UIColor colorWithRed:0.45 green:0.65 blue:1.00 alpha:1.00]; }
static UIColor *C_ACCENT2(void) { return [UIColor colorWithRed:0.75 green:0.45 blue:1.00 alpha:1.00]; }
static UIColor *C_TEXT(void)    { return [UIColor colorWithWhite:0.95 alpha:1.0]; }
static UIColor *C_SUB(void)     { return [UIColor colorWithWhite:0.60 alpha:1.0]; }

#pragma mark - Окно-оверлей (пропускает касания в игру)

@interface XantaWindow : UIWindow
@end

@implementation XantaWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self || v == self.rootViewController.view) return nil;
    return v;
}
@end

#pragma mark - Звёздное поле

@interface StarfieldView : UIView
@end

@implementation StarfieldView {
    NSMutableArray<CALayer *> *_stars;
    CADisplayLink *_link;
    CFTimeInterval _t;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        _stars = [NSMutableArray new];
        for (int i = 0; i < 60; i++) {
            CALayer *s = [CALayer layer];
            CGFloat sz = (arc4random_uniform(20) / 10.0) + 0.6;
            s.bounds = CGRectMake(0, 0, sz, sz);
            s.cornerRadius = sz / 2.0;
            s.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15 + (arc4random_uniform(70) / 100.0)].CGColor;
            s.position = CGPointMake(arc4random_uniform((uint32_t)frame.size.width),
                                     arc4random_uniform((uint32_t)frame.size.height));
            [self.layer addSublayer:s];
            [_stars addObject:s];
        }
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)tick:(CADisplayLink *)link {
    _t += link.duration;
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    for (CALayer *s in _stars) {
        CGPoint p = s.position;
        p.y += 0.25 + (s.bounds.size.width * 0.15);
        if (p.y > h) { p.y = -2; p.x = arc4random_uniform((uint32_t)w); }
        s.position = p;
        s.opacity = 0.6 + 0.4 * sin(_t * 2.0 + p.x * 0.05);
    }
}

- (void)dealloc { [_link invalidate]; }

@end

#pragma mark - Градиентная кнопка

@interface GradientButton : UIButton
@end

@implementation GradientButton {
    CAGradientLayer *_grad;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _grad = [CAGradientLayer layer];
        _grad.colors = @[(id)C_ACCENT().CGColor, (id)C_ACCENT2().CGColor];
        _grad.startPoint = CGPointMake(0, 0.5);
        _grad.endPoint = CGPointMake(1, 0.5);
        _grad.cornerRadius = 12;
        [self.layer insertSublayer:_grad atIndex:0];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _grad.frame = self.bounds;
}

@end

#pragma mark - Меню

@interface XantaMenu : UIView
@end

@implementation XantaMenu {
    UIView *_panel;
    UIView *_content;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        [self buildUI];
    }
    return self;
}

// Тап мимо панели проходит в игру, пока меню открыто
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    return v == self ? nil : v;
}

// Перетаскивание панели
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)buildUI {
    _panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kPanelW, kPanelH)];
    _panel.center = self.center;
    _panel.backgroundColor = C_BG();
    _panel.layer.cornerRadius = 22;
    _panel.layer.borderWidth = 1;
    _panel.layer.borderColor = [C_ACCENT() colorWithAlphaComponent:0.35].CGColor;
    _panel.layer.shadowColor = C_ACCENT().CGColor;
    _panel.layer.shadowOpacity = 0.35;
    _panel.layer.shadowRadius = 18;
    _panel.layer.shadowOffset = CGSizeZero;
    _panel.clipsToBounds = NO;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_panel addGestureRecognizer:pan];
    [self addSubview:_panel];

    StarfieldView *stars = [[StarfieldView alloc] initWithFrame:_panel.bounds];
    stars.layer.cornerRadius = 22;
    stars.clipsToBounds = YES;
    [_panel addSubview:stars];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, 220, 26)];
    title.text = kMenuTitle;
    title.textColor = C_TEXT();
    title.font = [UIFont systemFontOfSize:19 weight:UIFontWeightHeavy];
    [_panel addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(20, 44, 220, 16)];
    sub.text = kAuthorName;
    sub.textColor = C_SUB();
    sub.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [_panel addSubview:sub];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(kPanelW - 44, 16, 30, 30);
    [close setTitle:@"✕" forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [close setTitleColor:C_SUB() forState:UIControlStateNormal];
    [close addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [_panel addSubview:close];

    _content = [[UIView alloc] initWithFrame:CGRectMake(16, 70, kPanelW - 32, kPanelH - 70 - 16)];
    _content.layer.cornerRadius = 14;
    [_panel addSubview:_content];

    [self buildCreatorsTab];
}

- (void)buildCreatorsTab {
    UIView *v = [[UIView alloc] initWithFrame:_content.bounds];

    CGFloat w = v.bounds.size.width;

    UILabel *h = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, w, 22)];
    h.text = @"Creators";
    h.textAlignment = NSTextAlignmentCenter;
    h.textColor = C_TEXT();
    h.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    [v addSubview:h];

    UILabel *hsub = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, w, 16)];
    hsub.text = @"Автор меню";
    hsub.textAlignment = NSTextAlignmentCenter;
    hsub.textColor = C_SUB();
    hsub.font = [UIFont systemFontOfSize:12];
    [v addSubview:hsub];

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 70, w, 92)];
    card.backgroundColor = C_PANEL();
    card.layer.cornerRadius = 12;
    card.layer.borderWidth = 1;
    card.layer.borderColor = [C_ACCENT() colorWithAlphaComponent:0.25].CGColor;
    [v addSubview:card];

    UILabel *cTitle = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, w - 28, 18)];
    cTitle.text = @"Telegram-канал";
    cTitle.textColor = C_SUB();
    cTitle.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [card addSubview:cTitle];

    UILabel *cLink = [[UILabel alloc] initWithFrame:CGRectMake(14, 34, w - 28, 22)];
    cLink.text = kTGChannel;
    cLink.textColor = C_ACCENT();
    cLink.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [card addSubview:cLink];

    GradientButton *btn = [[GradientButton alloc] initWithFrame:CGRectMake(14, 60, w - 28, 24)];
    [btn setTitle:@"Открыть канал" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    [btn addTarget:self action:@selector(openChannel) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btn];

    UIView *card2 = [[UIView alloc] initWithFrame:CGRectMake(0, 174, w, 74)];
    card2.backgroundColor = C_PANEL();
    card2.layer.cornerRadius = 12;
    card2.layer.borderWidth = 1;
    card2.layer.borderColor = [C_ACCENT2() colorWithAlphaComponent:0.25].CGColor;
    [v addSubview:card2];

    UILabel *c2Title = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, w - 28, 18)];
    c2Title.text = @"Контакт";
    c2Title.textColor = C_SUB();
    c2Title.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [card2 addSubview:c2Title];

    UILabel *c2Link = [[UILabel alloc] initWithFrame:CGRectMake(14, 34, w - 28, 22)];
    c2Link.text = kTGHandle;
    c2Link.textColor = C_ACCENT2();
    c2Link.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [card2 addSubview:c2Link];

    UIButton *c2Btn = [UIButton buttonWithType:UIButtonTypeSystem];
    c2Btn.frame = CGRectMake(0, 0, w, 74);
    [c2Btn addTarget:self action:@selector(openHandle) forControlEvents:UIControlEventTouchUpInside];
    [card2 addSubview:c2Btn];

    UILabel *foot = [[UILabel alloc] initWithFrame:CGRectMake(0, 262, w, 16)];
    foot.text = kAuthorName;
    foot.textAlignment = NSTextAlignmentCenter;
    foot.textColor = [C_SUB() colorWithAlphaComponent:0.6];
    foot.font = [UIFont systemFontOfSize:11];
    [v addSubview:foot];

    [_content addSubview:v];
}

- (void)openChannel {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTGChannelURL] options:@{} completionHandler:nil];
}

- (void)openHandle {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTGHandleURL] options:@{} completionHandler:nil];
}

- (void)closeTapped {
    [self removeFromSuperview];
    extern void xantaShowButton(void);
    xantaShowButton();
}

@end

#pragma mark - Кнопка и окно

static XantaWindow *gWindow = nil;
static XantaMenu *gMenu = nil;
static UIButton *gButton = nil;

void xantaShowButton(void);

static void xantaEnsureWindow(void) {
    if (gWindow) return;
    gWindow = [[XantaWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    gWindow.windowLevel = UIWindowLevelAlert + 1000;
    gWindow.backgroundColor = [UIColor clearColor];
    gWindow.rootViewController = [UIViewController new];
    gWindow.hidden = NO;
}

static void xantaShowMenu(void) {
    xantaEnsureWindow();
    if (!gMenu) {
        gMenu = [[XantaMenu alloc] initWithFrame:gWindow.bounds];
    }
    gButton.hidden = YES;
    [gWindow.rootViewController.view addSubview:gMenu];
    gMenu.alpha = 0;
    gMenu.transform = CGAffineTransformMakeScale(0.92, 0.92);
    [UIView animateWithDuration:0.22 animations:^{
        gMenu.alpha = 1;
        gMenu.transform = CGAffineTransformIdentity;
    }];
}

void xantaShowButton(void) {
    xantaEnsureWindow();
    if (!gButton) {
        gButton = [UIButton buttonWithType:UIButtonTypeCustom];
        gButton.frame = CGRectMake(0, 0, 56, 56);
        gButton.center = CGPointMake(gWindow.bounds.size.width - 44, gWindow.bounds.size.height * 0.35);
        gButton.backgroundColor = [C_ACCENT() colorWithAlphaComponent:0.9];
        gButton.layer.cornerRadius = 28;
        gButton.layer.shadowColor = C_ACCENT().CGColor;
        gButton.layer.shadowOpacity = 0.6;
        gButton.layer.shadowRadius = 12;
        gButton.layer.shadowOffset = CGSizeZero;
        [gButton setTitle:@"✦" forState:UIControlStateNormal];
        [gButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        gButton.titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
        [gButton addTarget:gButton action:@selector(drag:event:) forControlEvents:UIControlEventTouchDragInside];
        [gButton addTarget:gButton action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
        [gWindow.rootViewController.view addSubview:gButton];
    }
    gButton.hidden = NO;
}

@interface UIButton (Xanta)
- (void)drag:(UIButton *)b event:(UIEvent *)e;
- (void)tapped;
@end

@implementation UIButton (Xanta)
- (void)drag:(UIButton *)b event:(UIEvent *)e {
    UITouch *t = e.allTouches.anyObject;
    if (!t) return;
    CGPoint p = [t locationInView:b.superview];
    b.center = p;
}
- (void)tapped {
    xantaShowMenu();
}
@end

#pragma mark - Точка входа

__attribute__((constructor))
static void xantaInit(void) {
    os_log(OS_LOG_DEFAULT, "[xantapers] libcheat v4 loaded into process");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        xantaShowButton();
    });
}
