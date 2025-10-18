///
/// AddEditTodoView.swift
/// TodoBar
///
/// 添加/编辑待办视图
///

import SwiftUI

struct AddEditTodoView: View {
    enum Mode {
        case add
        case edit(TodoItem)
        
        var title: String {
            switch self {
            case .add: return "新建待办"
            case .edit: return "编辑待办"
            }
        }
    }
    
    let mode: Mode
    let onSave: (TodoItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var priority: TodoItem.Priority = .medium
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    @State private var reminderDate: Date = Date()
    @State private var hasReminder: Bool = false
    @State private var notes: String = ""
    
    init(mode: Mode, onSave: @escaping (TodoItem) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        if case .edit(let item) = mode {
            _title = State(initialValue: item.title)
            _dueDate = State(initialValue: item.dueDate ?? Date())
            _hasDueDate = State(initialValue: item.dueDate != nil)
            _priority = State(initialValue: item.priority)
            _tags = State(initialValue: item.tags)
            _reminderDate = State(initialValue: item.reminderDate ?? Date())
            _hasReminder = State(initialValue: item.reminderDate != nil)
            _notes = State(initialValue: item.notes ?? "")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HeaderView(mode: mode, onCancel: { dismiss() }, onSave: handleSave)
                .padding()
            
            Divider()
            
            // 表单内容
            ScrollView {
                VStack(alignment: .leading, spacing: UIConstants.spacing) {
                    // 标题
                    VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                        Text("标题")
                            .font(.headline)
                        TextField("请输入待办事项标题", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // 截止日期
                    VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                        Toggle("截止日期", isOn: $hasDueDate)
                        
                        if hasDueDate {
                            DatePicker(
                                "选择日期",
                                selection: $dueDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
                    
                    // 优先级
                    VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                        Text("优先级")
                            .font(.headline)
                        
                        Picker("", selection: $priority) {
                            ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                                Text(priority.displayString).tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // 标签
                    VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                        Text("标签")
                            .font(.headline)
                        
                        // 已添加的标签
                        if !tags.isEmpty {
                            FlowLayout(spacing: UIConstants.smallSpacing) {
                                ForEach(tags, id: \.self) { tag in
                                    TagChip(tag: tag) {
                                        tags.removeAll { $0 == tag }
                                    }
                                }
                            }
                        }
                        
                        // 添加新标签
                        HStack {
                            TextField("添加标签", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("添加") {
                                if !newTag.isEmpty && !tags.contains(newTag) {
                                    tags.append(newTag)
                                    newTag = ""
                                }
                            }
                            .disabled(newTag.isEmpty)
                        }
                    }
                    
                    // 提醒时间
                    VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                        Toggle("提醒", isOn: $hasReminder)
                        
                        if hasReminder {
                            DatePicker(
                                "提醒时间",
                                selection: $reminderDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                    }
                    
                    // 备注
                    VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
                        Text("备注")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .cornerRadius(UIConstants.smallCornerRadius)
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 600)
    }
    
    // MARK: - Actions
    
    private func handleSave() {
        guard !title.isEmpty else { return }
        
        let item: TodoItem
        
        switch mode {
        case .add:
            item = TodoItem(
                title: title,
                dueDate: hasDueDate ? dueDate : nil,
                priority: priority,
                tags: tags,
                reminderDate: hasReminder ? reminderDate : nil,
                notes: notes.isEmpty ? nil : notes
            )
        case .edit(let existing):
            item = TodoItem(
                id: existing.id,
                title: title,
                dueDate: hasDueDate ? dueDate : nil,
                priority: priority,
                tags: tags,
                reminderDate: hasReminder ? reminderDate : nil,
                completed: existing.completed,
                notes: notes.isEmpty ? nil : notes,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
        }
        
        onSave(item)
        dismiss()
    }
}

// MARK: - Header View

struct HeaderView: View {
    let mode: AddEditTodoView.Mode
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            Text(mode.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button("取消", action: onCancel)
            Button("保存", action: onSave)
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, UIConstants.smallSpacing)
        .padding(.vertical, 4)
        .background(Color.themePrimary.opacity(0.2))
        .cornerRadius(UIConstants.smallCornerRadius)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

