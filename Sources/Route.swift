//
//  Route.swift
//  Route-UIKit
//
//  Created by Rain on 2024/10/22.
//

import UIKit

/// 全局队列执行
fileprivate func excuteInGlobal(_ closure: (()->Void)?) {
    DispatchQueue.global().async {
        closure?()
    }
}
/// 主队列执行
fileprivate func excuteInMain(_ closure: (()->Void)?) {
    DispatchQueue.main.async {
        closure?()
    }
}

/// 下一跳操作
fileprivate typealias nextRoute = ()->Void

/// 路由实体类
public final class Route {
    /// 私有shared属性 以类方法隐式调用
    internal static var shared = Route()
    private init() {}
    /// 导航节点
    private var naviNodes = [RouteNaviNode]()
    /// 是否初始化scheme
    private var isInstalledScheme: Bool = false
    /// 下一跳队列<未执行完保存下一跳>
    private var nextQueue: [nextRoute] = []
    /// 默认命名空间
    internal let ThisNameSpace: String = {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        return namespace
    }()
    /// 合法协议簇
    private var validSchemes = Set<String>()
    /// 路由节点注册
    private var routeNodes = [RouteExecNode]()
    /// 唯一路由节点
    private var uniqueNodes = [RouteExecNode]()
    /// 路由请求中间件
    private var reqMiddles = [RouteReqMiddleware]()
    /// 路由响应中间件
    private var respMiddles = [RouteResMiddleware]()
}

// MARK: 初始化相关(公开方法)
public extension Route {
    /// 注册模块 模块实现模块注册协议
    /// - Parameters:
    ///   - mds: 模块<实现模块注册协议主动添加路由协议类>
    ///   - at: 起始位置
    ///   - lock: 是否锁定模态行为
    class func registerModule(_ mds: [RouteRegisterable], start navi: UINavigationController) {
        excuteInGlobal {
            shared.registerModule(mds, start: navi)
        }
    }
    /// 注册模块 缺省主工程所有路由类
    /// - Parameters:
    ///   - modules: 模块<缺省为主工程>
    ///   - at: 起始位置
    ///   - lock: 是否锁定模态行为
    class func register(_ modules: [AnyClass]?, start at: UINavigationController) {
        var mds: [AnyClass] = []
        // 默认主工程
        if let app = UIApplication.shared.delegate {
            mds.append(type(of: app))
        }
        // 添加其他模块
        if let tmps = modules {
            mds.append(contentsOf: tmps)
        }
        excuteInGlobal {
            shared.register(mds, start: at)
        }
    }
    /// 注册请求中间件(效率太慢)
    class func register(req mids: [RouteReqMiddleware]) {
        excuteInGlobal {
            shared.register(req: mids)
        }
    }
    /// 注册响应中间件
    class func register(resp mids: [RouteResMiddleware]) {
        excuteInGlobal {
            shared.register(resp: mids)
        }
    }
}

// MARK: 初始化相关(私有方法)
internal extension Route {
    /// 注册模块 模块实现模块注册协议
    /// - Parameters:
    ///   - mds: 模块<实现模块注册协议主动添加路由协议类>
    ///   - at: 起始位置
    ///   - lock: 是否锁定模态行为
    @discardableResult
    private func registerModule(_ mds: [RouteRegisterable], start at: UINavigationController) -> Bool {
        for md in mds {
            let clses = md.registerModule()
            for cls in clses {
                registerClass(cls)
            }
        }
        dealRegisterNodes(at)
        return true
    }
    /// 注册模块 缺省主工程所有路由类
    /// - Parameters:
    ///   - modules: 模块<缺省为主工程>
    ///   - at: 起始位置
    @discardableResult
    private func register(_ modules: [AnyClass], start at: UINavigationController) -> Bool {
        // 分模块注册处理
        for md in modules {
            var counts: UInt32 = 0
            guard let imgName = class_getImageName(md) else {
                continue
            }
            guard let classNames = objc_copyClassNamesForImage(imgName, &counts) else {
                continue
            }
            for i in 0 ..< Int(counts) {
                if let clsName = String(cString: classNames[i], encoding: .utf8),
                   let cls = NSClassFromString(clsName) as? Routeable.Type {
                    registerClass(cls)
                }
            }
        }
        dealRegisterNodes(at)
        return true
    }
    /// 注册所有可路由到的场景控制器(从高优先级开始注册)
    private func registerClass(_ cls: Routeable.Type) {
        // 路由模式---UI路由
        if let tmp = cls as? UIRouteable.Type {
            #if DEBUG&&Logable
            debugPrint("默认cls:", cls)
            #endif
            self.validSchemes.formUnion((tmp.__schemes.map{$0.lowercased()}))
            self.routeNodes.append(RouteExecNode(tmp))
            let uniquetype = tmp.__uniqueType
            switch uniquetype {
            case .none:
                #if DEBUG&&Logable
                debugPrint("可忽略cls:", cls)
                #endif
            default:
                self.uniqueNodes.append(RouteExecNode(tmp))
            }
            return
        }
        // 路由模式---执行路由
        #if DEBUG&&Logable
        debugPrint("自定义cls:", cls)
        #endif
        self.routeNodes.append(RouteExecNode(cls))
        self.validSchemes.formUnion((cls.__schemes.map{$0.lowercased()}))
        return
    }
    /// 注册节点后后续处理
    private func dealRegisterNodes(_ navi: UINavigationController) {
        // 排序
        sortedRouteNodes()
        #if DEBUG&&Logable
        debugPrint("注册路由节点个数:", self.routeNodes.count)
        debugPrint("注册路由合法协议簇:", self.validSchemes)
        #endif
        // root navi 根导航控制器
        weak var ref = navi
        if let rf = ref {
            let root = RouteNaviNode(rf, previous: nil, trans: .none)
            self.naviNodes.append(root)
        }
        isInstalledScheme = true
        // 延后执行下一跳
        objc_sync_enter(nextQueue)
        nextQueue.last?()
        if let _ = nextQueue.last {
            nextQueue.removeLast()
        }
        objc_sync_exit(nextQueue)
    }
    /// 排序路由节点(由大到小 优先级越高越先被匹配)
    private func sortedRouteNodes() {
        self.routeNodes.sort { (nd0, nd1) -> Bool in
            return nd0.handler.__priority.rawValue > nd1.handler.__priority.rawValue
        }
    }
    /// 注册请求中间件
    private func register(req mids: [RouteReqMiddleware]) {
        self.reqMiddles.append(contentsOf: mids)
    }
    /// 注册响应中间件
    private func register(resp mids: [RouteResMiddleware]) {
        self.respMiddles.append(contentsOf: mids)
    }
    /// 调用中间件
    private func useMiddleware4(_ req: RouteRequest) -> RouteResponse? {
        //step1 调用请求中间件
        var resp: RouteResponse?
        for mid in self.reqMiddles {
            if let rsp = mid.process(req) {
                resp = rsp
                break
            }
        }
        //step2 调用响应中间件
        for mid in self.respMiddles {
            if let rsp = mid.process(resp, req: req) {
                resp = rsp
                break
            }
        }
        return resp
    }
}
    
// MARK: 跳转执行方法
internal extension Route {
    /// 是否可以处理路由 - URL
    func canOpen(_ url: URL?, options: [String: Any]?) -> Bool {
        guard let uri = url else {
            return false
        }
        // 首先处理协议簇 若不支持协议 则不处理
        guard self.validSchemes.contains(uri.schm) else {
            return false
        }
        // 其次生成request对象
        let req = RouteRequest(uri, from: nil, options: options)
        for it in self.routeNodes where it.reachable(req) {
            return true
        }
        return false
    }
    /// scheme/universal-link/弹窗链接等方式打开url
    /// - Parameters:
    ///   - url: 链接url
    ///   - options: 参数信息
    ///   - authGoResponse: 授权操作
    ///   - backpass: 数据回调   
    func open(_ url: URL?,
              options: [String: Any]?,
              authGoResponse: ClosureBackResponse?,
              backpass: ClosureAny? = nil) {
        let resp = urlResponse(url, options: options, authGoResponse: authGoResponse)?.backpass(backpass)
        execution(resp)
    }
    
    /// 路由path调用方式
    func go2(_ path: RoutePathable, options: Any?, backpass: ClosureAny? = nil) {
        let resp = pathResponse(path, options: options)?.backpass(backpass)
        execution(resp)
    }
    
    /// 直接转场切入(eg. 第三方SDK生成controller)
    func go2(_ resp: RouteResponse?) {
        execution(resp)
    }
}

// MARK: RouteResponse
internal extension Route {
    @discardableResult
    func urlResponse(_ url: URL?,
                     options: [String: Any]?,
                     authGoResponse: ClosureBackResponse?) -> RouteResponse? {
        let tmp = parseAndJoin(url, opts: options)
        var resp: RouteResponse?
        if let auth = tmp?["auth"] as? String,
           auth == "1" {
            resp = authGoResponse?()?.redirect(transform(url, options: tmp))
        }else {
            resp = transform(url, options: tmp)
        }
        return resp
    }
    
    @discardableResult
    /// 路由path调用方式
    func pathResponse(_ path: RoutePathable,
                      options: Any?) -> RouteResponse? {
        // 未初始完毕 先保存队列 延后执行
        guard isInstalledScheme else {
            let next: nextRoute = {[weak self] in
                excuteInMain {[weak self] in
                    self?.go2(path, options: options)
                }
            }
            nextQueue.append(next)
            return nil
        }
        
        let base = path.baseURL
        let (info, auth) = path.path
        let pathStr = base + info
        // url-encode
        guard let encoded = pathStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            assert(false, "route节点地址编码失败：nil!")
            return nil
        }
        // 路径授权相关
        if auth, path.authState == false {
            return path.enterOAuth()?.redirect(transform(URL(string: encoded), options: options))
        }
        return transform(URL(string: encoded), options: options)
    }
    /// 转换请求
    /// - Parameters:
    ///   - url: 路由链接
    ///   - options: 参数
    /// - Returns: RouteResponse
    private func transform(_ url: URL?, options: Any?) -> RouteResponse? {
        assert(isInstalledScheme == true, "You must call the method of `install(namespaces:[])` at first!")
        assert(naviNodes.count >= 1, "You must transform root navi controller to route center secondly!")
        // 来源viewController
        let fromVC = paramountVC()
        // 处理URL
        guard let uri = url else {
            assert(false, "route节点地址为空!")
            return nil
        }
        #if DEBUG&&Logable
        debugPrint("uri:", uri.absoluteString)
        #endif
        // 生成请求
        let req = RouteRequest(uri, from: fromVC, options: options)
        // 调用中间件
        if let tmpResp = useMiddleware4(req) {
            return tmpResp.redirect(transform(url, options: options))
        }
        
        // 首先处理协议簇 若不支持协议 则直接返回
        guard self.validSchemes.contains(uri.schm) else {
            assert(false, "不支持的协议")
            return nil
        }
        for unode in uniqueNodes {
            if let ui = unode.handler as? UIRouteable.Type {
                let path = ui.__pathName
                switch ui.__uniqueType {
                case .root:
                    if contains(uri.absoluteString, path) {
                        return transform2Root(unode, req)
                    }
                case .global:
                    if contains(uri.absoluteString, path) {
                        return transform2Global(unode, req)
                    }
                default:
                    debugPrint("无需处理")
                }
            }
        }
        return transform2Normal(req)
    }
    
    /// 根节点类型请求转换
    /// - Parameters:
    ///   - node: 目标节点
    ///   - req: 路由请求信息
    /// - Returns: RouteResponse
    private func transform2Root(_ node: RouteExecNode, _ req: RouteRequest) -> RouteResponse? {
        // 路径不可用
        guard node.reachable(req) else {
            assert(false, "节点不支持该Request")
            return nil
        }
        /// 确定导航栈内第一个栈是根视图
        guard let rootNaviNode = naviNodes.first,
              rootNaviNode.this == UIApplication.shared.keyWindow?.rootViewController else {
            assert(false, "导航根节点不是rootViewController")
            return nil
        }
        // 根据目标class类型，转场到对应vc
        if let classType = node.targetType() as? UIViewController.Type {
            return RouteResponse(from: req.from, obj: nil, transition: .none, uniqueType: .root, classType: classType, options: req.options)
        }
        assert(false, "目标class类型不是UIViewController")
        return nil
    }
    
    /// Global节点类型请求转换
    /// - Parameters:
    ///   - node: 目标节点
    ///   - req: 路由请求信息
    /// - Returns: RouteResponse
    private func transform2Global(_ node: RouteExecNode, _ req: RouteRequest) -> RouteResponse? {
        // 路径不可用
        guard node.reachable(req) else {
            assert(false, "节点不支持该Request")
            return nil
        }
        // 目标class类型
        let classType: AnyClass = node.targetType()
        for naviNode in naviNodes.reversed() {
            for vc in naviNode.this.viewControllers where vc.isMember(of: classType) {
                // 导航节点发现目标控制器，返回目标vc
                return RouteResponse(from: req.from, obj: vc, transition: .none, uniqueType: .global, classType: classType as? UIViewController.Type, options: req.options)
            }
        }
        // 导航节点没有发现目标控制器，普通转场
        return transform2Normal(req)
    }
    
    /// Normal节点类型请求转换
    /// - Parameters:
    ///   - node: 目标节点
    ///   - req: 路由请求信息
    /// - Returns: RouteResponse
    private func transform2Normal(_ req: RouteRequest) -> RouteResponse? {
        // 判断请求的节点是否在注册列表
        var didFound: Bool = false
        var tmpResp: RouteResponse?
        for node in self.routeNodes where node.reachable(req) {
            #if DEBUG&&Logable
            debugPrint("找到处理路由节点^_^:",node.handler)
            #endif
            didFound = true
            tmpResp = node.exe(req)
            break
        }
        assert(didFound, "未找到能处理路由的节点")
        return tmpResp
    }
}

// MARK: 执行路由
extension Route {
    /// 执行路由
    private func execution(_ resp: RouteResponse?) {
        guard let resp = resp else { return }
        // 转场到root
        if resp.uniqueType == .root, let vcType = resp.classType {
            back(resp.options, vcType: vcType, goHookPath: false, animated: true)
            return
        } else if resp.uniqueType == .global {
            guard let targetVC = resp.obj as? UIViewController else {
                return
            }
            if let routable = targetVC as? Routeable {
                routable.__routeOptions(data: resp.options)
            }
            // 导航节点发现目标控制器，返回目标vc
            back2Normal(targetVC: targetVC, animated: true)
            return
        }
        executionNormal(resp)
    }
    
    
    /// 执行普通Response
    /// - Parameter resp: 原Response
    /// - Returns: 新Response
    private func executionNormal(_ resp: RouteResponse?) {
        assert(resp != nil, "Response 不存在")
        assert(naviNodes.count > 0, "未找到当前视图控制器～")
        assert((resp?.obj as? UIViewController) != nil, "未找到目标视图控制器～")
        // 检查响应视图
        guard let resp = resp,
              let scene = resp.obj as? UIViewController,
              let last = naviNodes.last else {
            return
        }
        
        if let redirectResponse = resp.redirectResponse {
            resp.from?.routeRedirect = {[weak self] in
                self?.execution(redirectResponse)
            }
        }
        
        guard resp.transition == .present else {
            last.this.pushViewController(scene, animated: true)
            return
        }
        let newNavi = wrappByNavigationController(scene)
        newNavi.modalPresentationStyle = .fullScreen
        last.this.present(newNavi, animated: true, completion: nil)
        
        weak var weakLastNavi = last.this
        weak var ref = newNavi
        naviNodes.last?.update(ref)
        // 追加导航节点
        if let rf = ref {
            let node = RouteNaviNode(rf, previous: weakLastNavi, trans: resp.transition)
            naviNodes.append(node)
        }
    }
}

// MARK: 路由返回相关
public extension Route {
    /// 模态消失(dismiss navi)导航栈最顶层模态视图
    /// - Parameters:
    ///   - values: 反向传值
    ///   - goHookPath: 执行拦截路由(默认执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    @discardableResult
    internal func dismiss(_ values: Any? = nil, goHookPath: Bool = true, animated: Bool = true) -> UIViewController? {
        // 查找导航栈内第一个符合dismiss的导航控制器
        for naviNode in naviNodes.reversed() {
            if naviNode.transform == .present,
               let previous = naviNode.previous {
                // dismiss后的栈顶vc
                let targetVC = previous.viewControllers.last
                return back(values, targetVC: targetVC, goHookPath: goHookPath, animated: animated)
            }
        }
        return nil
    }
    /// 销毁(pop/dismiss)导航栈内控制器到对应的顶部path
    /// - Parameters:
    ///   - values: 反向传值
    ///   - path: RoutePathable路径
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    @discardableResult
    internal func back(_ values: Any? = nil, path goPath: RoutePathable, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        let pathString = goPath.path.0
        // 找到url对应的vc类型
        for node in routeNodes {
            // 找到符合的路径名的节点
            if contains(pathString, node.handler.__pathName),
               let vcType = node.handler.__classType() as? UIViewController.Type {
                return back(values, vcType: vcType, goHookPath: goHookPath, animated: animated)
            }
        }
        return nil
    }
    /// 销毁(pop/dismiss)导航栈内控制器到对应的顶部url
    /// - Parameters:
    ///   - values: 反向传值
    ///   - url: 目标对象url链接
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    @discardableResult
    internal func back(_ values: [String: Any]? = nil, url: URL?, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        // 首先处理协议簇 若不支持协议 则直接返回
        guard let uri = url, validSchemes.contains(uri.schm) else {
            return nil
        }
        let options = parseAndJoin(url, opts: values)
        // 找到url对应的vc类型
        for node in routeNodes {
            // 找到符合的路径名的节点
            if contains(uri.absoluteString, node.handler.__pathName),
               let vcType = node.handler.__classType() as? UIViewController.Type {
                return back(options, vcType: vcType, goHookPath: goHookPath, animated: animated)
            }
        }
        return nil
    }
    /// 销毁(pop/dismiss)导航栈内控制器到对应的顶部vcType
    /// - Parameters:
    ///   - values: 反向传值
    ///   - vcType: 目标控制器类型
    ///   - goHookPath: 执行拦截路由(默认不执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    @discardableResult
    internal func back(_ values: Any? = nil, vcType: UIViewController.Type, goHookPath: Bool = false, animated: Bool = true) -> UIViewController? {
        // 是rootVC
        if let node = naviNodes.first,
           node.transform == .none,
           let rootTab = node.this.viewControllers.first as? UITabBarController,
           let childVCs = rootTab.viewControllers {
            for vc in childVCs where vc.isMember(of: vcType) {
                // 切换回root参数传递
                if let routable = vc as? Routeable {
                    routable.__routeOptions(data: values)
                }
                return back(values, targetVC: vc, goHookPath: goHookPath, animated: animated)
            }
        }
        // 匹配控制器类型，找到导航栈内最后一个符合类型的vc
        for node in naviNodes.reversed() {
            for vc in node.this.viewControllers.reversed() where vc.isMember(of: vcType) {
                return back(values, targetVC: vc, goHookPath: goHookPath, animated: animated)
            }
        }
        return nil
    }
    /// 销毁(pop/dismiss)导航栈内控制器到目标控制器
    /// - Parameters:
    ///   - values: 反向传值
    ///   - targetVC: 目标控制器
    ///   - goHookPath: 执行拦截路由(默认执行)
    ///   - animated: 是否执行动画 默认true
    /// - Returns: 成功返回当前vc，失败返回nil
    @discardableResult
    internal func back(_ values: Any? = nil, targetVC: UIViewController? = nil, goHookPath: Bool = true, animated: Bool = true) -> UIViewController? {
        // 当前控制器或当前导航栈不存在
        guard let currentVC = paramountVC(), let lastNode = naviNodes.last else {
            debugPrint("failed to pop, current viewController or node for navis is empty")
            return nil
        }
        // 目标控制器
        weak var weakTargetVC = visible(targetVC)
        // 执行数据回传，或重定向执行闭包
        defer {
            windup(needGoRedirect: goHookPath, backVC: weakTargetVC, backValues: values)
        }
        let lastNavVCs = lastNode.this.viewControllers
        let stackCounts = lastNavVCs.count
        // 目标控制器为空时默认返回上一页面
        guard let targetVC = targetVC else {
            // 当前栈内对象大于1，可以执行pop；
            if stackCounts > 1 {
                lastNode.this.popViewController(animated: animated)
            }else if lastNode.transform == .none {// 当前导航节点是根节点，且当前视图为根视图
                return nil
            }else { // 执行dismiss，从导航节点移除当前导航栈
                lastNode.this.dismiss(animated: animated, completion: nil)
                naviNodes.removeLast()
                naviNodes.last?.update(nil)
            }
            weakTargetVC = visible(naviNodes.last?.this.viewControllers.last)
            return currentVC
        }
        var backResult = back2Root(targetVC: targetVC, animated: animated)
        if !backResult {// 不是TabBar的子vc
            backResult = back2Normal(targetVC: targetVC, animated: animated)
        }
        return backResult ? currentVC : nil
    }
    
    @discardableResult
    private func back2Root(targetVC: UIViewController, animated: Bool) -> Bool {
        // 找到根导航栈
        guard let node = naviNodes.first,
              node.transform == .none,
              let rootTab = node.this.viewControllers.first as? UITabBarController,
              let childVCs = rootTab.viewControllers,
              childVCs.contains(targetVC) else {
            return false
        }
        // 切换selectedIndex
        rootTab.selectedIndex = childVCs.firstIndex(of: targetVC) ?? 0
        // 销毁根导航栈下面的所有模态视图
        node.this.dismiss(animated: animated, completion: nil)
        // 根导航栈返回目标
        node.this.popToRootViewController(animated: animated)
        node.update(nil)
        naviNodes = [node]
        return true
    }
    @discardableResult
    private func back2Normal(targetVC: UIViewController, animated: Bool) -> Bool {
        // 目标控制器存在，查找在导航节点对应栈，及对应导航栈内对应位置
        var naviIndex: Int = NSNotFound
        for (index, naviNode) in naviNodes.enumerated().reversed() {
            if naviNode.this.viewControllers.contains(targetVC) {
                naviIndex = index
                break
            }
        }
        // 在导航栈未查找到目标vc
        guard naviIndex != NSNotFound else {
            return false
        }
        let targetLength = naviIndex + 1
        var needPopAnimated = animated
        if naviNodes.count > targetLength {
            let endNode = naviNodes[naviIndex]
            endNode.this.dismiss(animated: needPopAnimated, completion: nil)
            needPopAnimated = false
            endNode.update(nil)
            naviNodes = [RouteNaviNode](naviNodes.prefix(targetLength))
        }
        // pop到目标栈
        naviNodes.last?.this.popToViewController(targetVC, animated: needPopAnimated)
        return true
    }
    /// 路由重定向，页面数据回调
    /// - Parameters:
    ///   - needGoRedirect: 是否需要执行原路由
    ///   - backVC: 数据回传目标vc
    ///   - backValues: 回传数据
    private func windup(needGoRedirect: Bool, backVC: UIViewController?, backValues: Any? = nil) {
        guard let backVC = backVC else { return }
        // 首先检测重定向，并重定向数据回传vc
        if needGoRedirect,
           let routeRedirect = backVC.routeRedirect {
            routeRedirect()
        }else if let routeBackpass = backVC.routeBackpass {// 其次检测反向传值
            routeBackpass(backValues)
        }
        backVC.routeRedirect = nil
    }
    /// 精准判断手否包含对应路径名(pathName前/后?进行对比)
    private func contains(_ routePath: String, _ pathName: String) -> Bool {
        let newRoutePath = "\(routePath)?"
        return newRoutePath.contains("/\(pathName)?")
    }
}

// MARK: UI 层级操作
extension Route {
    /// UI层级最顶层控制器
    internal func paramountVC() -> UIViewController? {
        return visible(naviNodes.last?.this.visibleViewController)
    }
    /// UI顶层可见vc
    private func visible(_ from: UIViewController?) -> UIViewController? {
        var visibleVC = from
        if let rootTab = visibleVC as? UITabBarController {
            visibleVC = rootTab.selectedViewController
        }
        return visibleVC
    }
}

// MARK: 辅助方法
extension Route {
    /// navigationController包裹
    private func wrappByNavigationController(_ profile: UIViewController) -> UINavigationController {
        let wrappered = UINavigationController(rootViewController: profile)
        return wrappered
    }
    /// 默认转场
    private func defaultShowProfile(_ profile: UIViewController) {
        UIApplication.shared.keyWindow?.rootViewController?.show(profile, sender: nil)
    }
    /// url若包涵参数则解析 并合并url中的参数到已知参数中
    private func parseAndJoin(_ url: URL?, opts: [String: Any]?) -> [String: Any]? {
        guard let queryParams = url?.queryMap else {
            return opts
        }
        // 首先合并url参数
        var tmps: [String: Any] = queryParams
        // 其次合并传递参数
        if let olds = opts {
            for (k, v) in olds {
                tmps[k] = v
            }
        }
        return tmps
    }
}

extension URL {
    var schm: String {
        if let scheme = scheme?.lowercased() {
            return scheme
        }
        var sub_schm: String?
        if self.absoluteString.contains("://") {
            sub_schm = NSString(string: self.absoluteString).components(separatedBy: "://").first
        }
        return sub_schm ?? "http"
    }
    
    var queryMap: [String: Any]? {
        guard let coms = URLComponents(string: self.absoluteString), let its = coms.queryItems else {
            return nil
        }
        var tmp: [String: String] = [:]
        for it in its {
            tmp[it.name] = it.value
        }
        return tmp
    }
    var hostPath: String {
        let origin = host
        var sub_hostPath: String?
        // 如果失败则从path解析
        if origin == nil && NSString(string: path).contains("://") {
            if let suffix = NSString(string: path).components(separatedBy: "://").last {
                sub_hostPath = suffix
                if suffix.contains("?"), let prefix = NSString(string: suffix).components(separatedBy: "?").first {
                    sub_hostPath = prefix
                }
            }
        }
        guard let ori = origin else {
            return sub_hostPath ?? ""
        }
        return "\(ori)\(path)"
    }

}
