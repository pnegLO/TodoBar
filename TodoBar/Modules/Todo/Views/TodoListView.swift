///
/// TodoListView.swift
/// TodoBar
///
/// Todo 列表主视图
///

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var coordinator: PopoverCoordinator
    @EnvironmentObject var persistence: PersistenceController
    @StateObject private var viewModel: TodoListViewModel
    @State private var showAddSheet = false
    @State private var editingItem: TodoItem?
    
    init() {
        _viewModel = StateObject(wrappedValue: TodoListViewModel(
            persistence: PersistenceController.shared,
            notificationService: NotificationService()
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            ToolbarView(showAddSheet: $showAddSheet)
                .padding(.horizontal, UIConstants.spacing)
                .padding(.vertical, UIConstants.smallSpacing)
            
            // 搜索栏
            SearchBarView(
                searchKeyword: $viewModel.searchKeyword,
                selectedTags: $viewModel.selectedTags,
                availableTags: viewModel.allTags
            )
            .padding(.horizontal, UIConstants.spacing)
            .padding(.bottom, UIConstants.smallSpacing)
            
            Divider()
            
            // Todo 列表
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.todos.isEmpty {
                EmptyStateView()
            } else {
                TodoListContentView(
                    todos: viewModel.todos,
                    onToggle: { viewModel.toggleComplete($0) },
                    onEdit: { editingItem = $0 },
                    onDelete: { viewModel.deleteTodo($0) }
                )
            }
            
            Divider()
            
            // 底部统计
            StatisticsBar(viewModel: viewModel)
                .padding(.horizontal, UIConstants.spacing)
                .padding(.vertical, UIConstants.smallSpacing)
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditTodoView(mode: .add) { newItem in
                viewModel.addTodo(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            AddEditTodoView(mode: .edit(item)) { updatedItem in
                viewModel.updateTodo(updatedItem)
            }
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Toolbar View

struct ToolbarView: View {
    @Binding var showAddSheet: Bool
    
    var body: some View {
        HStack {
            Text("待办事项")
                .font(.headline)
                .foregroundColor(.themePrimaryText)
            
            Spacer()
            
            Button(action: { showAddSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: UIConstants.iconSize))
                    .foregroundColor(.themePrimary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Search Bar View

struct SearchBarView: View {
    @Binding var searchKeyword: String
    @Binding var selectedTags: [String]
    let availableTags: [String]
    @State private var showTagPicker = false
    
    var body: some View {
        HStack(spacing: UIConstants.smallSpacing) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.themeSecondaryText)
                
                TextField("搜索待办事项", text: $searchKeyword)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchKeyword.isEmpty {
                    Button(action: { searchKeyword = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.themeSecondaryText)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, UIConstants.smallSpacing)
            .padding(.vertical, 6)
            .background(Color.themeCardBackground)
            .cornerRadius(UIConstants.smallCornerRadius)
            
            // 标签过滤按钮
            Button(action: { showTagPicker.toggle() }) {
                Image(systemName: selectedTags.isEmpty ? "tag" : "tag.fill")
                    .foregroundColor(selectedTags.isEmpty ? .themeSecondaryText : .themePrimary)
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showTagPicker) {
                TagPickerView(selectedTags: $selectedTags, availableTags: availableTags)
            }
        }
    }
}

// MARK: - Tag Picker View

struct TagPickerView: View {
    @Binding var selectedTags: [String]
    let availableTags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.smallSpacing) {
            Text("选择标签")
                .font(.headline)
                .padding(.bottom, UIConstants.smallSpacing)
            
            if availableTags.isEmpty {
                Text("暂无标签")
                    .foregroundColor(.themeSecondaryText)
                    .padding()
            } else {
                ForEach(availableTags, id: \.self) { tag in
                    Button(action: {
                        if selectedTags.contains(tag) {
                            selectedTags.removeAll { $0 == tag }
                        } else {
                            selectedTags.append(tag)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedTags.contains(tag) ? "checkmark.square" : "square")
                            Text(tag)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if !selectedTags.isEmpty {
                Button("清除选择") {
                    selectedTags.removeAll()
                }
                .padding(.top, UIConstants.smallSpacing)
            }
        }
        .padding()
        .frame(width: 200)
    }
}

// MARK: - Todo List Content

struct TodoListContentView: View {
    let todos: [TodoItem]
    let onToggle: (TodoItem) -> Void
    let onEdit: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: UIConstants.smallSpacing) {
                ForEach(todos) { todo in
                    TodoRowView(
                        todo: todo,
                        onToggle: { onToggle(todo) },
                        onEdit: { onEdit(todo) },
                        onDelete: { onDelete(todo) }
                    )
                }
            }
            .padding(UIConstants.spacing)
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: UIConstants.spacing) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.themeSecondaryText)
            
            Text("暂无待办事项")
                .font(.headline)
                .foregroundColor(.themePrimaryText)
            
            Text("点击右上角 + 添加新的待办")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Statistics Bar

struct StatisticsBar: View {
    @ObservedObject var viewModel: TodoListViewModel
    
    var body: some View {
        HStack {
            Text("总数: \(viewModel.totalCount)")
                .font(.caption)
            
            Text("已完成: \(viewModel.completedCount)")
                .font(.caption)
            
            Text(String(format: "完成率: %.0f%%", viewModel.completionRate * 100))
                .font(.caption)
            
            Spacer()
        }
        .foregroundColor(.themeSecondaryText)
    }
}

