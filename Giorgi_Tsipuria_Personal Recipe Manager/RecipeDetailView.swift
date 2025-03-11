import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView { 
            VStack {
                Text(recipe.title)
                    .font(.largeTitle)
                Text(recipe.description).padding()

                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("No image available")
                        .foregroundColor(Color("Primary-color"))
                        .padding()
                }

                if recipe.status == .cooking {
                    VStack(alignment: .leading) {
                        Text("Cooking Progress: \(recipe.cookingProgress)%")
                            .frame(width: 200)
                        ProgressView(value: Double(recipe.cookingProgress), total: 100)
                            .frame(width: 200)
                            .padding(.top, 30)
                    }
                }

                NavigationLink("Update Recipe", destination: UpdateRecipeView(recipe: recipe, viewModel: viewModel))
                    .padding(.top, 30)
                Button("Delete Recipe") {
                    showingDeleteAlert = true
                }
                .padding(.top, 30)
            }
            .padding() 
        }
        .sheet(isPresented: $showingDeleteAlert) {
            DeleteRecipeView(recipe: recipe, viewModel: viewModel)
        }
    }
}
