# PodeIOS

PodeV1 的 iOS 客户端，使用 SwiftUI 开发。

## 功能特性

- [x] 用户登录与注册
- [x] 播客搜索与通过 RSS URL 添加
- [x] 首页单集时间线流
- [x] 播客播放功能（支持后台播放、进度同步）
- [x] 离线下载功能
- [x] 订阅管理
- [x] 播客详情与单集列表查看

## 项目结构

- `Sources/Models`: 数据模型
- `Sources/Services`: 网络请求、音频播放、下载管理服务
- `Sources/ViewModels`: 业务逻辑封装
- `Sources/Views`: SwiftUI 视图界面

## 如何运行

1. 确保已安装 Xcode 13+。
2. 在 Xcode 中创建一个新的 SwiftUI 项目，命名为 `PodeIOS`。
3. 将 `Sources` 目录下的所有文件拖入 Xcode 项目中。
4. 在 `Info.plist` 中添加 `NSAppTransportSecurity` 以允许连接本地服务器（如果是开发环境）。
5. 运行 `PodeSever` 后端服务。
6. 修改 `NetworkService.swift` 中的 `baseUrl` 为你的服务器地址。
7. 在模拟器或真机上编译运行。

## 依赖说明

目前项目采用原生开发，未引入第三方依赖，保持轻量级。
- 基础架构：SwiftUI + Combine/Async-Await
- 网络请求：URLSession
- 音频播放：AVFoundation
- 图片加载：AsyncImage
