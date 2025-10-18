# 📋 TodoBar

> **macOS 状态栏待办插件** - 高效管理你的任务和时间

TodoBar 是一个功能强大、界面优雅的 macOS 状态栏待办事项管理应用，支持 Todo 列表管理、Dashboard 统计、数据分析和番茄钟计时。

## ✨ 主要特性

### 🎯 核心功能

- **状态栏集成**：常驻系统状态栏，左键打开主界面，右键快速操作
- **Todo 管理**：完整的 CRUD 功能，支持优先级、标签、截止日期和提醒
- **Dashboard**：实时统计数据，可视化任务进度
- **番茄钟**：内置 Pomodoro 计时器，提升工作效率
- **数据分析**：完成趋势图、标签分布、数据导出（CSV/PDF）
- **个性化设置**：主题切换、开机自启、自动清理等

### 🎨 界面特色

```
┌───────────────────────────────────┐
│  macOS 状态栏                     │
│  ┌─────┐                          │
│  │ ⏰  │ ← 左键打开 / 右键菜单     │
│  └─────┘                          │
│         ↓                         │
│  ┌─────────────────────────────┐  │
│  │  📝 Todo | 📊 Dashboard    │  │
│  │  📈 Analytics | ⚙️ Settings│  │
│  └─────────────────────────────┘  │
└───────────────────────────────────┘
```

## 🏗️ 系统架构

### 技术栈

- **语言**：Swift 5.9+
- **框架**：SwiftUI, CoreData, Combine
- **最低版本**：macOS 14.0+
- **架构模式**：MVVM + Protocol-Oriented

### 目录结构

```
TodoBar/
├── App/                          # 应用入口
│   ├── TodoBarApp.swift         # 主入口
│   └── AppDelegate.swift        # 应用委托
├── Common/                       # 公共代码
│   ├── Models/                  # 数据模型
│   ├── Protocols/               # 协议定义
│   ├── Extensions/              # 扩展
│   ├── Constants/               # 常量
│   └── Persistence/             # CoreData
├── Modules/                      # 功能模块
│   ├── StatusBar/               # 状态栏模块
│   ├── Popover/                 # Popover 容器
│   ├── Todo/                    # 待办模块
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   └── Services/
│   ├── Dashboard/               # 仪表盘模块
│   ├── Analytics/               # 分析模块
│   └── Settings/                # 设置模块
├── Resources/                    # 资源文件
│   ├── Assets.xcassets/
│   └── Localizable.xcstrings
└── Tests/                        # 测试
    ├── Unit/
    ├── Mocks/
    └── UITests/
```

## 🚀 快速开始

### 环境要求

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

### 构建步骤

```bash
# 1. 克隆仓库
git clone https://github.com/yourusername/TodoBar.git
cd TodoBar

# 2. 打开项目
open TodoBar.xcodeproj

# 3. 构建运行
⌘ + R
```

### 开发工具

```bash
# 运行 SwiftLint 检查
swiftlint

# 运行单元测试
xcodebuild test -scheme TodoBar

# 构建 Release 版本
xcodebuild -scheme TodoBar -configuration Release
```

## 📖 功能详解

### 1️⃣ StatusBar 模块

**功能**：管理状态栏图标和交互

- 左键：打开 Popover 主界面
- 右键：显示快捷菜单
  - ✚ 新建待办
  - 📊 Dashboard
  - 📈 数据分析
  - ⚙️ 设置
  - 退出应用

### 2️⃣ Todo 模块

**功能**：完整的待办事项管理

```
┌─────────────────────────────────┐
│ [+] 新建待办    🔍 搜索          │
├─────────────────────────────────┤
│ ☐ 工作报告  ★★  #工作  ⏰09:00 │
│ ☐ 读论文    ★   #学习           │
│ ☑︎ 会议准备  ★★★ #会议           │
├─────────────────────────────────┤
│ 总数: 12  已完成: 3  (25%)      │
└─────────────────────────────────┘
```

**特性**：
- ✅ 添加/编辑/删除待办
- 🏷️ 标签分类管理
- ⭐ 三级优先级
- 📅 截止日期设置
- ⏰ 提醒通知
- 🔍 搜索和过滤
- 📝 备注支持

### 3️⃣ Dashboard 模块

**功能**：实时统计和番茄钟计时

```
┌─────────────────────────────────┐
│ 🍅 番茄钟: 25:00  [开始]        │
├─────────────────────────────────┤
│ ┌──────┐ ┌──────┐              │
│ │总数12│ │完成4 │              │
│ └──────┘ └──────┘              │
│        ◯ 33%                    │
├─────────────────────────────────┤
│ [全部完成] [延迟1天] [延迟3天]  │
└─────────────────────────────────┘
```

**特性**：
- 📊 实时统计卡片
- 🍅 Pomodoro 计时器
- ⏱️ 工作/休息自动切换
- 🔔 完成提醒
- 📈 进度可视化

### 4️⃣ Analytics 模块

**功能**：数据分析和导出

```
┌─────────────────────────────────┐
│ 📅 [最近7天] [最近30天]         │
├─────────────────────────────────┤
│ 📈 任务完成趋势                 │
│    ──▂▃▅▇▆▅▃▂──                │
├─────────────────────────────────┤
│ 📊 标签占比                     │
│    工作 40%  学习 35%  其他 25% │
├─────────────────────────────────┤
│ 📤 [导出 CSV] [导出 PDF]        │
└─────────────────────────────────┘
```

**特性**：
- 📈 完成趋势折线图
- 🥧 标签分布图
- 📊 多维度数据统计
- 💾 CSV/PDF 导出

### 5️⃣ Settings 模块

**功能**：全局配置管理

**设置项**：
- 🚀 开机自启
- 🎨 主题模式（系统/浅色/深色）
- ⏰ 默认提醒方式
- 🍅 番茄钟时长配置
- 🗑️ 自动清理已完成任务
- 💾 数据备份与恢复

## 🧪 测试

### 单元测试

```bash
# 运行所有单元测试
xcodebuild test -scheme TodoBar -destination 'platform=macOS'

# 运行特定测试
xcodebuild test -scheme TodoBar -only-testing:TodoBarTests/TodoListViewModelTests
```

### Mock 实现

所有协议都提供了 Mock 实现，便于单元测试：

```swift
// 示例：使用 Mock
let mockPersistence = MockTodoPersisting()
let viewModel = TodoListViewModel(
    persistence: mockPersistence,
    notificationService: MockNotificationService()
)
```

## 📝 代码规范

### SwiftLint

项目使用 SwiftLint 进行代码风格检查：

```bash
# 安装 SwiftLint
brew install swiftlint

# 运行检查
swiftlint

# 自动修复
swiftlint --fix
```

### 命名约定

- **文件**：PascalCase + 后缀（如 `TodoListView.swift`）
- **类/结构体**：PascalCase
- **方法/属性**：camelCase
- **协议**：动词或能力描述（如 `TodoPersisting`）
- **常量**：enum 封装（如 `UIConstants.spacing`）

## 🛠️ 依赖管理

项目不依赖第三方库，仅使用 Apple 原生框架：

- SwiftUI - UI 框架
- CoreData - 数据持久化
- Combine - 响应式编程
- Charts - 数据可视化
- UserNotifications - 本地通知

## 📦 打包发布

### 构建 Release 版本

```bash
# 归档
xcodebuild archive \
  -scheme TodoBar \
  -configuration Release \
  -archivePath build/TodoBar.xcarchive

# 导出 .app
xcodebuild -exportArchive \
  -archivePath build/TodoBar.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ExportOptions.plist
```

### 创建 DMG

```bash
# 使用 create-dmg 工具
create-dmg \
  --volname "TodoBar" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 185 \
  TodoBar.dmg \
  build/TodoBar.app
```

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

### 提交规范

使用 Conventional Commits 规范：

```
feat: 添加新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建/工具链更新
```

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 📧 联系方式

- **作者**：Your Name
- **邮箱**：support@todobar.app
- **网站**：https://todobar.app
- **问题反馈**：https://github.com/yourusername/TodoBar/issues

## 🙏 致谢

感谢所有贡献者和支持者！

---

**Made with ❤️ for macOS**

