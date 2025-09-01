import SwiftUI

struct TodosView: View {
    @State private var showingTodosErrorAlert = false
    @Environment(Auth.self) private var auth
    @State private var todos: [Todo] = []
    let apiHostname: String
    let todosRequest: ResourceRequest<Todo>

    init(apiHostname: String, myTodos: Bool = false) {
        self.apiHostname = apiHostname
        if myTodos {
            self.todosRequest = ResourceRequest<Todo>(apiHostname: apiHostname, resourcePath: "todos/mine")
        } else {
            self.todosRequest = ResourceRequest<Todo>(apiHostname: apiHostname, resourcePath: "todos")
        }
    }

    var body: some View {
        NavigationView {
            List {
                // swiftlint:disable:next trailing_closure
                ForEach(todos, id: \.id) { todo in
                    Text(todo.title).font(.title2)
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
            let todos = try await todosRequest.getAll()
            self.todos = todos
        } catch {
            self.showingTodosErrorAlert = true
        }
    }
}

#Preview {
    TodosView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
