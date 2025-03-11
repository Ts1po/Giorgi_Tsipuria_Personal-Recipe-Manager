import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RecipeViewModel()
    @State private var showingAddRecipe = false
    @State private var showingRecycleBin = false

    var body: some View {
        NavigationView {
            List {
                ForEach(RecipeStatus.allCases, id: \.self) { status in
                    Section(header: Text(status.rawValue)) {
                        let filteredRecipes = viewModel.recipes.filter { $0.status == status }
                        if filteredRecipes.isEmpty {
                            Text("No recipes in this category.")
                                .foregroundColor(Color("Primary-color"))
                                .padding(.leading, 20)
                        } else {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                                    Text(recipe.title)
                                        .font(.system(size: 18))
                                        .padding(.leading, 20)
                                        .foregroundColor(Color("Primary-color"))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recipes")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color("Primary-color"))
                        .padding(.top, 30)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingRecycleBin = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.top, 30)
                    }

                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus.app.fill")
                            .padding(.top, 30)
                            .foregroundColor(Color("plus-color"))
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingRecycleBin) {
                RecycleBinView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
