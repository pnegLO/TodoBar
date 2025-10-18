# 🚀 TodoBar 快速开始指南

> 5 分钟快速启动 TodoBar 项目

---

## ⚡ 极速上手

### 1. 环境检查 ✅

确保你的开发环境满足以下要求：

```bash
# 检查 macOS 版本（需要 14.0+）
sw_vers

# 检查 Xcode 版本（需要 15.0+）
xcodebuild -version

# 检查 Swift 版本（需要 5.9+）
swift --version
```

### 2. 安装工具 🛠️

```bash
# 安装 SwiftLint（可选但推荐）
brew install swiftlint

# 验证安装
swiftlint version
```

### 3. 运行项目 🎯

```bash
# 方法 1：使用 Xcode（推荐）
open TodoBar.xcodeproj
# 然后按 ⌘ + R 运行

# 方法 2：使用命令行
xcodebuild -scheme TodoBar -configuration Debug
```

### 4. 首次运行 👀

应用启动后：

1. **状态栏图标**：在屏幕右上角找到 ⏰ 图标
2. **左键点击**：打开主界面
3. **右键点击**：显示快捷菜单
4. **授权通知**：点击"允许"以启用提醒功能

---

## 📚 核心功能体验

### Todo 管理

```
1. 点击状态栏图标
2. 点击右上角 [+] 按钮
3. 填写待办信息：
   - 标题：工作报告
   - 优先级：★★
   - 标签：#工作
   - 截止日期：明天
   - 提醒：今天 18:00
4. 点击 [保存]
```

### Pomodoro 计时

```
1. 切换到 Dashboard Tab
2. 在番茄钟区域点击 [开始]
3. 专注工作 25 分钟
4. 休息 5 分钟
5. 查看完成的番茄钟统计
```

### 数据分析

```
1. 切换到 Analytics Tab
2. 选择日期范围（最近 7 天 / 30 天）
3. 查看完成趋势图和标签分布
4. 点击 [导出 CSV] 或 [导出 PDF]
```

### 个性化设置

```
1. 切换到 Settings Tab
2. 配置：
   - 🎨 主题：浅色/深色/系统
   - 🚀 开机自启：ON
   - 🍅 番茄时长：25 分钟
   - 💾 自动清理：30 天
```

---

## 🧪 测试和调试

### 运行单元测试

```bash
# 方法 1：使用脚本
./Scripts/test.sh

# 方法 2：使用 Xcode
⌘ + U

# 方法 3：使用命令行
xcodebuild test -scheme TodoBar -destination 'platform=macOS'
```

### 代码质量检查

```bash
# 运行 SwiftLint
./Scripts/lint.sh

# 或直接使用
swiftlint
```

### 调试技巧

**1. 打印日志**：
```swift
print("🐛 Debug: \(variable)")
```

**2. 断点调试**：
- 在代码行号左侧点击添加断点
- ⌘ + R 运行后会在断点处暂停

**3. View Hierarchy**：
- 运行应用后，点击 Xcode 底部的 🔍 图标
- 查看 SwiftUI 视图层级

---

## 🎨 自定义开发

### 添加新的 Todo 字段

**1. 更新模型**（`TodoItem.swift`）：
```swift
struct TodoItem {
    // 添加新字段
    var customField: String?
}
```

**2. 更新 CoreData 实体**（`TodoItemEntity+CoreData.swift`）：
```swift
@NSManaged public var customField: String?
```

**3. 更新 UI**（`AddEditTodoView.swift`）：
```swift
TextField("Custom Field", text: $customField)
```

### 添加新的统计图表

**1. 创建 ViewModel**：
```swift
class NewChartViewModel: ObservableObject {
    @Published var data: [ChartData] = []
    
    func loadData() {
        // 实现数据加载
    }
}
```

**2. 创建 View**：
```swift
struct NewChartView: View {
    @StateObject var viewModel = NewChartViewModel()
    
    var body: some View {
        Chart(viewModel.data) { item in
            // 使用 SwiftUI Charts
        }
    }
}
```

**3. 集成到 AnalyticsView**：
```swift
NewChartView()
    .padding()
```

---

## 📖 项目结构速览

```
TodoBar/
├── 📱 App/                     # 入口
│   ├── TodoBarApp.swift       # SwiftUI 入口
│   └── AppDelegate.swift      # 状态栏初始化
│
├── 🧩 Common/                  # 公共代码
│   ├── Models/                # 数据模型
│   ├── Protocols/             # 协议定义
│   ├── Persistence/           # CoreData
│   └── Extensions/            # 扩展
│
├── 🎯 Modules/                 # 功能模块
│   ├── StatusBar/             # 状态栏
│   ├── Popover/               # Tab 容器
│   ├── Todo/                  # 待办管理
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   └── Services/
│   ├── Dashboard/             # 仪表盘
│   ├── Analytics/             # 数据分析
│   └── Settings/              # 设置
│
└── 🧪 Tests/                   # 测试
    ├── Unit/
    └── Mocks/
```

---

## 🔧 常见问题

### Q1: 运行时提示"开发者无法验证"？

**解决方案**：
```bash
# 打开系统偏好设置
# → 安全性与隐私
# → 通用
# → 点击"仍要打开"
```

### Q2: 状态栏图标不显示？

**检查**：
1. 确认 `Info.plist` 中 `LSUIElement` = `true`
2. 重启应用
3. 查看 Console.app 日志

### Q3: CoreData 读取失败？

**调试步骤**：
```swift
// 在 PersistenceController.swift 添加错误日志
container.loadPersistentStores { description, error in
    if let error = error {
        print("❌ CoreData Error: \(error)")
        fatalError()
    }
}
```

### Q4: 通知不弹出？

**检查权限**：
```bash
# 系统偏好设置
# → 通知
# → TodoBar
# → 确保"允许通知"已开启
```

---

## 📞 获取帮助

### 文档资源

- 📖 [完整文档](README.md) - 详细功能说明
- 🏗️ [架构设计](PROJECT_OVERVIEW.md) - 系统架构
- 🤝 [贡献指南](CONTRIBUTING.md) - 如何贡献

### 社区支持

- 💬 [GitHub Issues](https://github.com/yourusername/TodoBar/issues) - 报告问题
- 📧 [邮件支持](mailto:support@todobar.app) - 技术咨询

### 学习资源

- [SwiftUI 官方文档](https://developer.apple.com/documentation/swiftui/)
- [CoreData 编程指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)
- [Combine 框架](https://developer.apple.com/documentation/combine)

---

## 🎓 下一步

### 进阶学习

1. **深入 MVVM**：阅读 `TodoListViewModel.swift` 的实现
2. **掌握 Combine**：研究数据流如何从 CoreData 到 UI
3. **理解协议**：查看 `Protocols.swift` 的设计思想

### 功能扩展

- [ ] 添加子任务功能
- [ ] 集成 iCloud 同步
- [ ] 实现全局快捷键
- [ ] 支持 Markdown 备注
- [ ] 添加更多主题

### 贡献代码

1. Fork 项目
2. 创建功能分支
3. 提交 Pull Request
4. 参与 Code Review

---

## ✅ 检查清单

开始开发前，确保：

- [ ] ✅ macOS 14.0+ 和 Xcode 15.0+
- [ ] ✅ 已安装 SwiftLint
- [ ] ✅ 项目能正常编译运行
- [ ] ✅ 通知权限已授权
- [ ] ✅ 阅读了 README.md

开始贡献前，确保：

- [ ] ✅ 阅读了 CONTRIBUTING.md
- [ ] ✅ 了解项目架构（PROJECT_OVERVIEW.md）
- [ ] ✅ 运行过单元测试
- [ ] ✅ 代码通过 SwiftLint 检查

---

## 🎉 开始你的旅程！

现在你已经准备好了！打开 Xcode，开始探索 TodoBar 的代码吧！

```bash
open TodoBar.xcodeproj
```

**祝你编码愉快！** 🚀

---

**需要帮助？** 查看 [完整文档](README.md) 或 [提交 Issue](https://github.com/yourusername/TodoBar/issues)

