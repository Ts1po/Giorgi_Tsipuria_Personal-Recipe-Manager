import SwiftUI
import PhotosUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct UpdateRecipeView: View {
    var recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: RecipeStatus = .toCook
    @State private var cookingProgress: Double = 0
    @State private var estimatedTime: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var recipeImage: UIImage? = nil
    @State private var showCamera = false
    @State private var navigateToContentView = false

    init(recipe: Recipe, viewModel: RecipeViewModel) {
        self.recipe = recipe
        self.viewModel = viewModel
        _title = State(initialValue: recipe.title)
        _description = State(initialValue: recipe.description)
        _status = State(initialValue: recipe.status)
        _estimatedTime = State(initialValue: recipe.estimatedTime != nil ? String(recipe.estimatedTime!) : "")
        _imageData = State(initialValue: recipe.imageData)

        if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
            _recipeImage = State(initialValue: uiImage)
        }
    }

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

                if status == .cooking {
                    Section(header: Text("Cooking Progress")) {
                        Slider(value: $cookingProgress, in: 0...100, step: 1)
                        Text("\(Int(cookingProgress))% Complete")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color("Sec-color"))
                    }
                }

                Section(header: Text("Recipe Image").font(.title2).bold()) {
                    if let uiImage = recipeImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(10)
                            .shadow(radius: 5)
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
                                    recipeImage = uiImage
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
                    .sheet(isPresented: $showCamera) {
                        CameraView(image: $recipeImage)
                    }
                }
            }
            .navigationTitle("Update Recipe")
            .onAppear {
                title = recipe.title
                description = recipe.description
                status = recipe.status 
                estimatedTime = recipe.estimatedTime != nil ? String(recipe.estimatedTime!) : ""
                imageData = recipe.imageData
            }

            .toolbar {
                Button("Save") {
                    // for debug
                    print("Updated Status: \(status.rawValue)")
                    // Validate if the fields are not empty
                    guard !title.isEmpty, !description.isEmpty else {
                        return
                    }

                    let updatedRecipe = Recipe(
                            id: recipe.id,
                            title: title,
                            description: description,
                            status: status,
                            cookingProgress: cookingProgress, estimatedTime: Int(estimatedTime) ?? 0,
                            imageData: imageData ?? recipe.imageData
                        )

                        viewModel.updateRecipe(updatedRecipe)

                        navigateToContentView = true
                }
                .disabled(title.isEmpty || description.isEmpty)
            }
            .padding()
            .background(
                NavigationLink(destination: ContentView(), isActive: $navigateToContentView) {
                    EmptyView()
                }
            )
        }
    }
}
