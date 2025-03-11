//
//  RecycleBinView.swift
//  IOS_Final
//
//  Created by George Tsipuria on 3/6/25.
//

import SwiftUI

struct RecycleBinView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.recycleBin) { recipe in
                    VStack(alignment: .leading, spacing: 10) {
                        // Title
                        Text(recipe.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("Primary-color"))
                        
                        // Deletion Date
                        if let deletionDate = recipe.deletionDate {
                            Text("Deleted: \(deletionDate, style: .date)")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(Color("Sec-color"))
                            
                            Text(timeRemaining(from: deletionDate))
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        // Restore Button
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.restoreRecipe(recipe)
                            }) {
                                Text("Restore")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color("Secondaty-color"))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .shadow(radius: 5)
                            }
                            .padding(.top, 15)
                        }
                    }
                    .padding()
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .navigationTitle("Recycle Bin")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .listStyle(InsetGroupedListStyle())
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    private func timeRemaining(from deletionDate: Date) -> String {
        let fourWeeks: TimeInterval = 4 * 7 * 24 * 60 * 60
        let removalDate = deletionDate.addingTimeInterval(fourWeeks)
        let now = Date()
        let remainingTime = removalDate.timeIntervalSince(now)

        if remainingTime > 0 {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            return "Removes in: \(formatter.string(from: remainingTime) ?? "Unknown")"
        } else {
            return "Ready to be removed."
        }
    }
}

