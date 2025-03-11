import Foundation

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var cookedRecipes: [Recipe] = []
    @Published var recycleBin: [Recipe] = []
    private let recipesFile = "recipes.json"
    private let recycleBinFile = "bin.json"

    init() {
        loadRecipes()
        loadRecycleBin()
    }
    
    // add recipe func
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
    }
    
    // update recipe func
    func updateRecipe(_ updatedRecipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            recipes[index] = updatedRecipe
            saveRecipes()
        }
    }

    // delete recipe func
    func deleteRecipe(_ recipe: Recipe) {
        var mutableRecipe = recipe
        mutableRecipe.deletionDate = Date()
        recipes.removeAll { $0.id == recipe.id }
        recycleBin.append(mutableRecipe)
        saveRecipes()
        saveRecycleBin()
        cleanupRecycleBin()
    }
    
    // restore recipe func
    func restoreRecipe(_ recipe: Recipe) {
        recycleBin.removeAll { $0.id == recipe.id }
        recipes.append(recipe)
        saveRecipes()
        saveRecycleBin()
    }
    
    // clean recycle bin func
    private func cleanupRecycleBin() {
        let fourWeeks: TimeInterval = 4 * 7 * 24 * 60 * 60
        let now = Date()

        recycleBin.removeAll { recipe in
            guard let deletionDate = recipe.deletionDate else { return false }
            return now.timeIntervalSince(deletionDate) > fourWeeks
        }
        saveRecycleBin()
    }
    
    // load func
    private func loadRecipes() {
        recipes = loadJSON(from: recipesFile) ?? []
    }
    
    // save func
    private func saveRecipes() {
        saveJSON(recipes, to: recipesFile)
    }

    // load recycle bin func
    private func loadRecycleBin() {
        recycleBin = loadJSON(from: recycleBinFile) ?? []
    }
    
    // save recycle bin func
    private func saveRecycleBin() {
        saveJSON(recycleBin, to: recycleBinFile)
    }
    
    
    // load json
    private func loadJSON<T: Decodable>(from filename: String) -> T? {
        guard let url = getFileURL(filename),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // save json
    private func saveJSON<T: Encodable>(_ object: T, to filename: String) {
        guard let url = getFileURL(filename),
              let data = try? JSONEncoder().encode(object) else { return }
        try? data.write(to: url)
    }

    private func getFileURL(_ filename: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }
}
