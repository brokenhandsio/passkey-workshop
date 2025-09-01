import SwiftUI

struct TodosView: View {
    @State private var showingTodosErrorAlert = false
    @Environment(Auth.self) private var auth
    @State private var todos: [Todo] = []
    @State private var displayAddNewTodo = false
    let apiHostname: String
    let todosRequest: ResourceRequest<Todo>
    let myTodos: Bool

    init(apiHostname: String, myTodos: Bool = false) {
        self.apiHostname = apiHostname
        self.myTodos = myTodos
        if myTodos {
            self.todosRequest = ResourceRequest<Todo>(apiHostname: apiHostname, resourcePath: "todos/mine")
        } else {
            self.todosRequest = ResourceRequest<Todo>(apiHostname: apiHostname, resourcePath: "todos")
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if todos.isEmpty {
                    Text("No todos created")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        // swiftlint:disable:next trailing_closure
                        ForEach(todos, id: \.id) { todo in
                            Text(todo.title).font(.title2)
                        }
                    }
                }
            }
            .navigationTitle(self.myTodos ? "My Todos" : "Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { displayAddNewTodo = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $displayAddNewTodo) {
                CreateTodoView(apiHostname: self.apiHostname) { newTodo in
                    self.todos.append(newTodo)
                }
            }
        }
        .modifier(ResponsiveNavigationStyle())
        .task {
            await loadData()
        }
        .alert(isPresented: $showingTodosErrorAlert) {
            Alert(title: Text("Error"), message: Text("There was an error getting the todos"))
        }
    }

    @MainActor
    func loadData() async {
        do {
            let todos = try await todosRequest.getAll(auth: auth)
            self.todos = todos
        } catch {
            self.showingTodosErrorAlert = true
        }
    }
}

#Preview {
    TodosView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
