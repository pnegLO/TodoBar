# 📋 TodoBar 项目总览

> 本文档提供项目的完整架构说明和开发指南

## 📁 项目结构树

```
TodoBar/
├── TodoBar/                                    # 主应用目录
│   ├── App/                                   # 应用入口
│   │   ├── TodoBarApp.swift                  # SwiftUI App 入口
│   │   └── AppDelegate.swift                 # NSApplication 委托
│   │
│   ├── Common/                                # 公共代码层
│   │   ├── Models/                           # 数据模型
│   │   │   ├── TodoItem.swift               # 待办事项模型
│   │   │   ├── DailyStat.swift              # 每日统计模型
│   │   │   └── Enums.swift                  # 枚举定义
│   │   │
│   │   ├── Protocols/                        # 协议定义（依赖倒置）
│   │   │   └── Protocols.swift              # 所有协议
│   │   │
│   │   ├── Extensions/                       # 扩展
│   │   │   ├── Notification+Names.swift     # 通知名称
│   │   │   └── Color+Theme.swift            # 主题颜色
│   │   │
│   │   ├── Constants/                        # 常量
│   │   │   └── UIConstants.swift            # UI 常量
│   │   │
│   │   └── Persistence/                      # CoreData 层
│   │       ├── PersistenceController.swift   # 持久化控制器
│   │       ├── TodoItemEntity+CoreData.swift # Todo 实体
│   │       ├── DailyStatEntity+CoreData.swift# 统计实体
│   │       └── TodoBar.xcdatamodeld/         # CoreData 模型文件
│   │
│   ├── Modules/                               # 功能模块（MVVM 架构）
│   │   │
│   │   ├── StatusBar/                        # 状态栏模块
│   │   │   └── StatusBarController.swift    # 状态栏控制器
│   │   │
│   │   ├── Popover/                          # Popover 容器
│   │   │   ├── PopoverCoordinator.swift     # 协调器
│   │   │   └── Views/
│   │   │       └── PopoverView.swift        # 主视图
│   │   │
│   │   ├── Todo/                             # 待办模块
│   │   │   ├── ViewModels/
│   │   │   │   └── TodoListViewModel.swift  # 列表 ViewModel
│   │   │   ├── Views/
│   │   │   │   ├── TodoListView.swift       # 列表视图
│   │   │   │   ├── TodoRowView.swift        # 行视图
│   │   │   │   └── AddEditTodoView.swift    # 添加/编辑视图
│   │   │   └── Services/
│   │   │       └── NotificationService.swift # 通知服务
│   │   │
│   │   ├── Dashboard/                        # 仪表盘模块
│   │   │   ├── ViewModels/
│   │   │   │   └── DashboardViewModel.swift # Dashboard ViewModel
│   │   │   ├── Views/
│   │   │   │   ├── DashboardView.swift      # Dashboard 视图
│   │   │   │   └── PomodoroTimerView.swift  # 番茄钟视图
│   │   │   └── Services/
│   │   │       └── PomodoroService.swift    # 番茄钟服务
│   │   │
│   │   ├── Analytics/                        # 分析模块
│   │   │   ├── ViewModels/
│   │   │   │   └── AnalyticsViewModel.swift # Analytics ViewModel
│   │   │   ├── Views/
│   │   │   │   └── AnalyticsView.swift      # Analytics 视图
│   │   │   └── Services/
│   │   │       ├── AnalyticsService.swift   # 分析服务
│   │   │       └── ExportService.swift      # 导出服务
│   │   │
│   │   └── Settings/                         # 设置模块
│   │       ├── Views/
│   │       │   └── SettingsView.swift       # 设置视图
│   │       └── Services/
│   │           ├── SettingsService.swift    # 设置服务
│   │           └── BackupService.swift      # 备份服务
│   │
│   └── Resources/                             # 资源文件
│       ├── Assets.xcassets/                  # 图片资源
│       └── Localizable.xcstrings             # 本地化字符串
│
├── Tests/                                     # 测试目录
│   ├── Unit/                                 # 单元测试
│   │   └── TodoListViewModelTests.swift     # ViewModel 测试
│   └── Mocks/                                # Mock 实现
│       ├── MockTodoPersisting.swift         # Mock 持久化
│       └── MockNotificationService.swift    # Mock 通知
│
├── Scripts/                                   # 脚本工具
│   ├── lint.sh                               # SwiftLint 检查脚本
│   └── test.sh                               # 测试运行脚本
│
├── Info.plist                                 # 应用配置
├── .swiftlint.yml                            # SwiftLint 配置
├── README.md                                  # 项目说明
└── PROJECT_OVERVIEW.md                        # 本文档
```

## 🎯 架构说明

### MVVM + Protocol-Oriented 架构

```
┌─────────────────────────────────────────────────────────────┐
│                         View (SwiftUI)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ TodoListView │  │DashboardView │  │AnalyticsView │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │ @StateObject      │                │              │
└─────────┼───────────────────┼────────────────┼──────────────┘
          │                   │                │
┌─────────▼───────────────────▼────────────────▼──────────────┐
│                      ViewModel Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │TodoViewModel │  │DashboardVM   │  │AnalyticsVM   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │ @Published       │                │              │
└─────────┼───────────────────┼────────────────┼──────────────┘
          │ Protocol          │                │
┌─────────▼───────────────────▼────────────────▼──────────────┐
│                      Service Layer                           │
│  ┌──────────────────┐  ┌─────────────────┐  ┌─────────────┐│
│  │TodoPersisting    │  │PomodoroTiming   │  │Exporting    ││
│  │(Protocol)        │  │(Protocol)       │  │(Protocol)   ││
│  └──────┬───────────┘  └──────┬──────────┘  └──────┬──────┘│
│         │                     │                     │       │
│  ┌──────▼───────────┐  ┌──────▼──────────┐  ┌──────▼──────┐│
│  │Persistence       │  │PomodoroService  │  │ExportService││
│  │Controller        │  │                 │  │             ││
│  └──────┬───────────┘  └─────────────────┘  └─────────────┘│
└─────────┼──────────────────────────────────────────────────┘
          │
┌─────────▼──────────────────────────────────────────────────┐
│                      Data Layer (CoreData)                  │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │TodoItemEntity│  │DailyStatEntity│                       │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### 依赖注入流程

```swift
// 1. 在 App 入口注入全局服务
@main
struct TodoBarApp: App {
    @StateObject private var persistence = PersistenceController.shared
    @StateObject private var settings = SettingsService()
    
    var body: some Scene {
        Settings {
            ContentView()
                .environmentObject(persistence)
                .environmentObject(settings)
        }
    }
}

// 2. 在 ViewModel 中依赖协议
class TodoListViewModel: ObservableObject {
    private let persistence: TodoPersisting  // 协议，非具体类
    
    init(persistence: TodoPersisting) {
        self.persistence = persistence
    }
}

// 3. 在测试中注入 Mock
let mock = MockTodoPersisting()
let vm = TodoListViewModel(persistence: mock)
```

## 📊 数据流设计

### 1. Todo 数据流（Combine）

```
User Action
    ↓
[TodoListView] ────┐
    ↓              │
[TodoViewModel]    │
    ↓              │
[Persistence] ─────┤
    ↓              │
CoreData           │
    ↓              │
NSManagedContext   │
    ↓              │
NotificationCenter ← (todosDidChange)
    ↓
[ViewModel] ← 自动刷新
    ↓
[View] ← UI 更新
```

### 2. 事件总线（NotificationCenter）

```
┌─────────────────┐
│  StatusBar      │
│   (左键/右键)    │
└────────┬────────┘
         │ post(.openAddTodo)
         ↓
┌────────▼────────┐
│NotificationCenter│
└────────┬────────┘
         │ observe(.openAddTodo)
         ↓
┌────────▼────────┐
│Popover          │
│Coordinator      │
└────────┬────────┘
         │ selectTab(.todoList)
         │ showAddSheet = true
         ↓
┌────────▼────────┐
│  TodoListView   │
│  (显示添加弹窗) │
└─────────────────┘
```

## 🔧 核心功能实现

### Todo 管理

**核心类**：`TodoListViewModel`

**功能**：
- ✅ CRUD 操作
- 🔍 搜索和过滤
- 🏷️ 标签管理
- ⏰ 提醒通知
- 📊 统计计算

**关键方法**：
```swift
func addTodo(_ item: TodoItem)
func updateTodo(_ item: TodoItem)
func deleteTodo(_ item: TodoItem)
func toggleComplete(_ item: TodoItem)
func search(keyword: String, tags: [String], completed: Bool?)
```

### Dashboard 统计

**核心类**：`DashboardViewModel`

**功能**：
- 📈 实时统计
- 🍅 番茄钟集成
- ⚡ 快速操作

**数据源**：
```swift
Publishers.Zip(
    persistence.fetchAll(),          // 待办列表
    analyticsService.fetchDailyStats() // 每日统计
)
```

### Analytics 分析

**核心类**：`AnalyticsViewModel`

**功能**：
- 📊 趋势图表（SwiftUI Charts）
- 🥧 标签分布
- 💾 数据导出（CSV/PDF）

**导出实现**：
```swift
func exportCSV(stats: [DailyStat]) throws -> URL
func exportPDF(stats: [DailyStat], tagDistribution: [...]) throws -> URL
```

### Settings 配置

**核心类**：`SettingsService`

**功能**：
- 🚀 开机自启（SMAppService）
- 🎨 主题切换（NSAppearance）
- 💾 备份恢复（CoreData 迁移）

## 🧪 测试策略

### 单元测试覆盖

- ✅ ViewModels（80%+ 覆盖率）
- ✅ Services（核心业务逻辑）
- ✅ Extensions（辅助函数）

### Mock 实现

```swift
// Mock 示例
class MockTodoPersisting: TodoPersisting {
    var todos: [TodoItem] = []
    
    func fetchAll() -> AnyPublisher<[TodoItem], Error> {
        Just(todos)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func add(_ item: TodoItem) throws {
        todos.append(item)
    }
}
```

## 🎨 UI/UX 设计原则

### 1. 一致性

- 统一使用 `UIConstants` 定义间距、圆角等
- 所有颜色通过 `Color+Theme` 扩展
- 图标使用 SF Symbols

### 2. 响应式

- 使用 `@Published` 自动更新 UI
- Combine 流式数据处理
- 异步操作使用 `async/await`

### 3. 可访问性

- 所有交互元素设置 `accessibilityIdentifier`
- 支持 VoiceOver
- 键盘导航友好

## 🔐 安全性

### 数据安全

- ✅ 所有数据仅本地存储
- ✅ CoreData 使用 SQLite 加密（可选）
- ✅ 备份文件不包含敏感信息

### 权限管理

- ✅ 通知权限请求（UNUserNotificationCenter）
- ✅ 文件访问沙盒限制
- ✅ 开机自启需用户授权

## 📈 性能优化

### 1. 数据加载

- 使用 `LazyVStack` 懒加载列表
- CoreData 分页查询（可扩展）
- 图片资源使用 Asset Catalog

### 2. 内存管理

- ViewModel 使用 `weak self` 避免循环引用
- Combine 订阅存储在 `cancellables`
- Timer 在 deinit 时正确释放

### 3. UI 渲染

- 避免过度嵌套视图
- 使用 `.id()` 强制刷新关键视图
- Charts 数据限制在合理范围

## 🚀 部署清单

### 打包前检查

- [ ] 运行 SwiftLint（`./Scripts/lint.sh`）
- [ ] 运行所有测试（`./Scripts/test.sh`）
- [ ] 更新版本号（Info.plist）
- [ ] 签名证书配置
- [ ] 公证配置（Notarization）

### 构建步骤

```bash
# 1. Clean Build
xcodebuild clean

# 2. Archive
xcodebuild archive -scheme TodoBar -archivePath build/TodoBar.xcarchive

# 3. Export
xcodebuild -exportArchive -archivePath build/TodoBar.xcarchive \
           -exportPath build/ -exportOptionsPlist ExportOptions.plist

# 4. Create DMG
create-dmg --volname "TodoBar" TodoBar.dmg build/TodoBar.app
```

## 📝 开发备忘

### 常用命令

```bash
# 运行 Lint
./Scripts/lint.sh

# 运行测试
./Scripts/test.sh

# 清理构建
xcodebuild clean

# 生成文档
jazzy --module TodoBar
```

### Git 工作流

```bash
# 功能分支
git checkout -b feature/new-feature

# 提交（遵循 Conventional Commits）
git commit -m "feat: add new feature"

# 推送
git push origin feature/new-feature
```

## 🔗 相关资源

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [CoreData Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [Combine Framework](https://developer.apple.com/documentation/combine)

---

**最后更新**：2024-10-18  
**文档版本**：1.0.0

