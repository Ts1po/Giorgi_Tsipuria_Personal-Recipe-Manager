import SwiftUI

struct DeleteRecipeView: View {
    var recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Are you sure you want to delete \(recipe.title)?")
                .font(.system(size: 18, weight: .bold))
                .padding()
                .foregroundColor(Color("Primary-color"))
                .multilineTextAlignment(.center)

            HStack {
                Button("Delete") {
                    viewModel.deleteRecipe(recipe)
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)

                Button("Cancel") {
                    dismiss()
                }
                .padding()
                .background(Color("Cancel-color"))
                .foregroundColor(.white)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .navigationTitle("Delete Recipe")
    }
}
