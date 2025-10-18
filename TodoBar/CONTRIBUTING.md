# 🤝 贡献指南

感谢您考虑为 TodoBar 做出贡献！本文档提供了参与项目的指南。

## 📋 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们承诺：

- 使用友好和包容的语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表现出同理心

## 🚀 如何贡献

### 报告 Bug

在提交 Bug 报告之前，请：

1. 检查 [Issues](https://github.com/yourusername/TodoBar/issues) 确认问题未被报告
2. 准备以下信息：
   - macOS 版本
   - TodoBar 版本
   - 重现步骤
   - 预期行为
   - 实际行为
   - 截图（如适用）

**Bug 报告模板**：

```markdown
### 描述
简短描述问题

### 重现步骤
1. 打开...
2. 点击...
3. 看到错误...

### 预期行为
应该发生什么

### 实际行为
实际发生了什么

### 环境
- macOS: 14.0
- TodoBar: 1.0.0
```

### 建议新功能

在提交功能建议之前，请：

1. 确认功能未在 Roadmap 中
2. 思考功能是否符合项目目标
3. 提供清晰的用例

**功能建议模板**：

```markdown
### 功能描述
清晰描述建议的功能

### 使用场景
为什么需要这个功能？

### 建议实现
如何实现这个功能（可选）

### 替代方案
是否考虑过其他方案？
```

## 💻 开发流程

### 环境设置

1. **Fork 项目**

```bash
# Clone 你的 fork
git clone https://github.com/YOUR_USERNAME/TodoBar.git
cd TodoBar
```

2. **添加上游仓库**

```bash
git remote add upstream https://github.com/ORIGINAL_OWNER/TodoBar.git
```

3. **安装工具**

```bash
# SwiftLint
brew install swiftlint

# SwiftFormat (可选)
brew install swiftformat
```

### 开发规范

#### 代码风格

- 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 使用 SwiftLint 检查（`.swiftlint.yml`）
- 所有 public API 必须有文档注释

**示例**：

```swift
/// 添加新的待办事项到列表
///
/// - Parameter item: 要添加的待办事项
/// - Throws: 如果持久化失败则抛出错误
func addTodo(_ item: TodoItem) throws {
    // 实现...
}
```

#### Git 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具链更新

**示例**：

```bash
feat(todo): add priority filter

Add a new filter option to sort todos by priority level.

Closes #123
```

#### 分支命名

```
feature/功能名称   - 新功能
bugfix/问题描述    - Bug 修复
hotfix/紧急修复    - 生产环境紧急修复
docs/文档更新      - 文档相关
refactor/重构描述  - 代码重构
```

### Pull Request 流程

1. **创建分支**

```bash
git checkout -b feature/amazing-feature
```

2. **开发和测试**

```bash
# 运行 lint
./Scripts/lint.sh

# 运行测试
./Scripts/test.sh

# 提交代码
git add .
git commit -m "feat: add amazing feature"
```

3. **同步上游**

```bash
git fetch upstream
git rebase upstream/main
```

4. **推送分支**

```bash
git push origin feature/amazing-feature
```

5. **创建 PR**

- 填写 PR 模板
- 链接相关 Issue
- 等待 Code Review

### Code Review 标准

#### 必须满足

- ✅ 通过所有测试
- ✅ 通过 SwiftLint 检查
- ✅ 代码覆盖率 ≥ 80%
- ✅ 文档完整
- ✅ 没有 TODO/FIXME

#### 审查要点

- 代码可读性
- 架构设计
- 性能影响
- 安全性
- 向后兼容性

## 🧪 测试规范

### 单元测试

每个 ViewModel 和 Service 必须有对应的测试：

```swift
final class TodoListViewModelTests: XCTestCase {
    var sut: TodoListViewModel!
    var mockPersistence: MockTodoPersisting!
    
    override func setUp() {
        super.setUp()
        mockPersistence = MockTodoPersisting()
        sut = TodoListViewModel(persistence: mockPersistence)
    }
    
    func testAddTodo() {
        // Given
        let item = TodoItem(title: "Test")
        
        // When
        sut.addTodo(item)
        
        // Then
        XCTAssertEqual(mockPersistence.todos.count, 1)
    }
}
```

### 测试覆盖率

- ViewModel: ≥ 80%
- Service: ≥ 70%
- View: UI 测试覆盖关键流程

## 📝 文档规范

### 代码注释

```swift
/// 简短描述（单行）
///
/// 详细描述（可选，多行）
///
/// - Parameters:
///   - param1: 参数1描述
///   - param2: 参数2描述
/// - Returns: 返回值描述
/// - Throws: 可能抛出的错误
func someFunction(param1: String, param2: Int) throws -> String {
    // 实现...
}
```

### README 更新

添加新功能时，请更新：

- README.md（功能说明）
- PROJECT_OVERVIEW.md（架构说明）
- CHANGELOG.md（变更日志）

## 🎯 优先级标签

Issue 和 PR 使用以下标签：

- `priority: critical` - 紧急修复
- `priority: high` - 高优先级
- `priority: medium` - 中优先级
- `priority: low` - 低优先级
- `good first issue` - 适合新手
- `help wanted` - 需要帮助

## 📞 联系方式

如有疑问，请通过以下方式联系：

- **Issues**: [GitHub Issues](https://github.com/yourusername/TodoBar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/TodoBar/discussions)
- **Email**: support@todobar.app

## 📜 许可证

通过贡献代码，您同意您的贡献将使用与项目相同的 [MIT 许可证](LICENSE) 进行授权。

---

再次感谢您的贡献！🎉

