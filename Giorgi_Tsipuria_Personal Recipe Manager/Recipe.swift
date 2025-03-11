import Foundation

struct Recipe: Codable, Identifiable {
    var id: UUID
    var title: String
    var description: String
    var status: RecipeStatus
    var cookingProgress: Double = 0.0
    var estimatedTime: Int?
    var images: [String] = []
    var deletionDate: Date?
    var imageData: Data?

    init(id: UUID = UUID(), title: String, description: String, status: RecipeStatus, cookingProgress: Double = 0.0, estimatedTime: Int?, imageData: Data?) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.cookingProgress = cookingProgress
        self.estimatedTime = estimatedTime
        self.imageData = imageData
    }
}


enum RecipeStatus: String, Codable, CaseIterable {
    case cooked = "Cooked"
    case cooking = "Cooking"
    case toCook = "To Cook"
}
