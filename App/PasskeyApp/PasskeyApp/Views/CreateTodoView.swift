import SwiftUI

struct CreateTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newTodo = ""
    @State private var showingCreateError = false
    let apiHostname: String
    @Environment(Auth.self) private var auth
    var onAdd: (Todo) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Buy some eggs", text: $newTodo)
            }
            .navigationTitle("Add Todo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    AsyncButton("Save") {
                        if let todo = try await createTodo() {
                            onAdd(todo)
                            dismiss()
                        }
                    }.disabled(newTodo.isEmpty)
                }
            }
        }
        .alert(isPresented: $showingCreateError) {
            Alert(title: Text("Error"), message: Text("There was an error creating the todo. Please try again later."))
        }
    }

    @MainActor
    func createTodo() async throws -> Todo? {
        let createTodoData = CreateTodoRequest(title: newTodo)
        do {
            let todo = try await ResourceRequest<Todo>(apiHostname: self.apiHostname, resourcePath: "todos").save(createTodoData, auth: auth)
            return todo
        } catch {
            self.showingCreateError = true
        }
        return nil
    }
}

#Preview {
    CreateTodoView(apiHostname: PasskeyApp.apiHostname, onAdd: { _ in }).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
