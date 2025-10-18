///
/// TodoRowView.swift
/// TodoBar
///
/// Todo 列表行视图
///

import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: UIConstants.smallSpacing) {
            // 完成复选框
            Button(action: onToggle) {
                Image(systemName: todo.completed ? "checkmark.square.fill" : "square")
                    .font(.system(size: UIConstants.iconSize))
                    .foregroundColor(todo.completed ? .themeSuccess : .themeSecondaryText)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                // 标题
                Text(todo.title)
                    .font(.body)
                    .foregroundColor(todo.completed ? .themeSecondaryText : .themePrimaryText)
                    .strikethrough(todo.completed)
                
                // 详细信息
                HStack(spacing: UIConstants.smallSpacing) {
                    // 截止日期
                    if let dueDate = todo.dueDate {
                        Label(
                            formatDate(dueDate),
                            systemImage: "calendar"
                        )
                        .font(.caption)
                        .foregroundColor(isOverdue(dueDate) ? .themeError : .themeSecondaryText)
                    }
                    
                    // 优先级
                    Text(todo.priority.displayString)
                        .font(.caption)
                        .foregroundColor(priorityColor(todo.priority))
                    
                    // 标签
                    ForEach(todo.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.themePrimary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.themePrimary.opacity(0.1))
                            .cornerRadius(UIConstants.smallCornerRadius)
                    }
                    
                    if todo.tags.count > 2 {
                        Text("+\(todo.tags.count - 2)")
                            .font(.caption)
                            .foregroundColor(.themeSecondaryText)
                    }
                    
                    // 提醒
                    if todo.reminderDate != nil {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(.themeWarning)
                    }
                }
            }
            
            Spacer()
            
            // 悬停时显示操作按钮
            if isHovering {
                HStack(spacing: 4) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: UIConstants.smallIconSize))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: UIConstants.smallIconSize))
                            .foregroundColor(.themeError)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(UIConstants.smallSpacing)
        .background(Color.themeCardBackground)
        .cornerRadius(UIConstants.cornerRadius)
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date() && !todo.completed
    }
    
    private func priorityColor(_ priority: TodoItem.Priority) -> Color {
        switch priority {
        case .low: return .priorityLow
        case .medium: return .priorityMedium
        case .high: return .priorityHigh
        }
    }
}

