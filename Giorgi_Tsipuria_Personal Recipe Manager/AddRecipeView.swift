import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var status: RecipeStatus = .toCook
    @State private var estimatedTime: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var recipeImage: Image? = nil
    @State private var imageData: Data? = nil
    @State private var showCamera = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details").font(.title2).bold()) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 5)

                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 5)

                    Picker("Status", selection: $status) {
                        ForEach(RecipeStatus.allCases, id: \.self) { status in
                            Text(status.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 5)

                    TextField("Estimated Time (minutes)", text: $estimatedTime)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 5)
                }

                Section(header: Text("Recipe Image").font(.title2).bold()) {
                    if let image = recipeImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(10)
                    } else {
                        Text("No image selected")
                            .foregroundColor(Color("Primary-color"))
                    }

                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Select Image")
                    }
                    .onChange(of: selectedImage) {oldItem, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    recipeImage = Image(uiImage: uiImage)
                                    imageData = data
                                }
                            }
                        }
                    }

                    Button("Take Photo") {
                        showCamera = true
                    }
                    .padding()
                    .background(Color("plus-color"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Add Recipe")
            .toolbar {
                Button("Save") {
                    let recipe = Recipe(
                        title: title,
                        description: description,
                        status: status,
                        estimatedTime: Int(estimatedTime),
                        imageData: imageData
                    )
                    viewModel.addRecipe(recipe)
                    dismiss()
                }
                .disabled(title.isEmpty || description.isEmpty)
            }
            .padding()
        }
    }
}
