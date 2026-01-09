//
//  LearningManager.swift
//  GlycaReset V71
//
//  Created by Mohamad Alayouni on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

class LearningManager: ObservableObject {
    static let shared = LearningManager()
    
    @Published var modules: [LearningModule] = []
    @Published var tests: [Test] = []
    @Published var successStories: [SuccessStory] = []
    
    private let modulesKey = "learning_modules"
    private let testsKey = "learning_tests"
    private let storiesKey = "success_stories"
    
    private init() {
        loadModules()
        loadTests()
        loadSuccessStories()
        initializeDefaultModules()
        syncSuccessStoriesFromPublishedHabits()
    }
    
    // MARK: - Progress Tracking
    
    var totalLessons: Int {
        return modules.flatMap { $0.lessons }.count
    }
    
    var completedLessons: Int {
        return modules.flatMap { $0.lessons }.filter { $0.isCompleted }.count
    }
    
    var overallProgress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }
    
    var overallProgressPercentage: Int {
        return Int(overallProgress * 100)
    }
    
    var totalXPEarned: Int {
        var total = 0
        for module in modules {
            if module.isCompleted {
                total += module.xpReward
            }
        }
        return total
    }
    
    // MARK: - Module Management
    
    func completeLesson(lessonId: UUID, moduleId: UUID) {
        if let moduleIndex = modules.firstIndex(where: { $0.id == moduleId }),
           let lessonIndex = modules[moduleIndex].lessons.firstIndex(where: { $0.id == lessonId }) {
            var updatedLesson = modules[moduleIndex].lessons[lessonIndex]
            updatedLesson.isCompleted = true
            
            var updatedLessons = modules[moduleIndex].lessons
            updatedLessons[lessonIndex] = updatedLesson
            
            var updatedModule = modules[moduleIndex]
            updatedModule = LearningModule(
                id: updatedModule.id,
                title: updatedModule.title,
                description: updatedModule.description,
                icon: updatedModule.icon,
                lessons: updatedLessons,
                xpReward: updatedModule.xpReward,
                isLocked: updatedModule.isLocked,
                unlockRequirement: updatedModule.unlockRequirement,
                order: updatedModule.order
            )
            
            modules[moduleIndex] = updatedModule
            saveModules()
            
            // Award XP for completing a lesson (10 XP per lesson)
            DailyGoalsManager.shared.awardXP(10)
            
            // Check if module is now completed
            if updatedModule.isCompleted {
                DailyGoalsManager.shared.awardXP(updatedModule.xpReward)
            }
        }
    }
    
    func unlockModule(_ moduleId: UUID) {
        if let index = modules.firstIndex(where: { $0.id == moduleId }) {
            var module = modules[index]
            // Check if prerequisites are met
            let previousModules = modules.filter { $0.order < module.order }
            let allPreviousCompleted = previousModules.allSatisfy { $0.isCompleted }
            
            if allPreviousCompleted {
                module = LearningModule(
                    id: module.id,
                    title: module.title,
                    description: module.description,
                    icon: module.icon,
                    lessons: module.lessons,
                    xpReward: module.xpReward,
                    isLocked: false,
                    unlockRequirement: module.unlockRequirement,
                    order: module.order
                )
                modules[index] = module
                saveModules()
            }
        }
    }
    
    // MARK: - Test Management
    
    func completeTest(_ test: Test, score: Double) {
        var updatedTest = test
        updatedTest.isCompleted = true
        updatedTest.score = score
        
        if let index = tests.firstIndex(where: { $0.id == test.id }) {
            tests[index] = updatedTest
        } else {
            tests.append(updatedTest)
        }
        
        saveTests()
        
        // Award XP based on score (50 XP for passing, 100 XP for perfect score)
        if score >= 0.8 {
            DailyGoalsManager.shared.awardXP(score == 1.0 ? 100 : 50)
        }
    }
    
    func getTest(for moduleId: UUID) -> Test? {
        return tests.first { $0.moduleId == moduleId }
    }
    
    // MARK: - Success Stories
    
    func syncSuccessStoriesFromPublishedHabits() {
        let habitsManager = HabitsManager.shared
        let publishedHabits = habitsManager.publishedHabits
        
        // Convert published habits to success stories
        for publishedHabit in publishedHabits {
            // Check if story already exists
            if successStories.contains(where: { $0.publishedHabitId == publishedHabit.id }) {
                continue
            }
            
            // Extract key changes from simplified steps or description
            let keyChanges = publishedHabit.simplifiedSteps?.map { $0.title } ?? []
            
            // Calculate star rating from helpful percentage
            // helpfulPercentage is 0-100, convert to 0-5 stars
            let helpfulPercentage = publishedHabit.helpfulPercentage
            let starRating = (helpfulPercentage / 100.0) * 5.0
            
            // Generate default remission info (in production, this would come from user profile)
            let remissionMonths = Int.random(in: 6...12) // Placeholder
            let remissionYears = Int.random(in: 1...3) // Placeholder
            
            let story = SuccessStory(
                publishedHabitId: publishedHabit.id,
                authorUsername: publishedHabit.authorUsername,
                authorAvatar: "👤", // Default avatar, could be enhanced
                remissionStatus: "REVERSED IN \(remissionMonths) MONTHS",
                remissionDuration: "In remission for \(remissionYears) year\(remissionYears > 1 ? "s" : "")",
                strategy: publishedHabit.description,
                keyChanges: keyChanges.isEmpty ? [publishedHabit.title] : keyChanges,
                likes: publishedHabit.helpfulRatings,
                xpEarned: 500, // Default XP for publishing
                starRating: min(5.0, max(0.0, starRating)),
                adoptionCount: publishedHabit.helpfulRatings, // Use helpful ratings as adoption count
                publishedAt: publishedHabit.publishedAt
            )
            
            successStories.append(story)
        }
        
        // Sort by helpful ratings (most helpful first)
        successStories.sort { $0.starRating > $1.starRating }
        
        saveSuccessStories()
    }
    
    func likeStory(_ storyId: UUID) {
        if let index = successStories.firstIndex(where: { $0.id == storyId }) {
            var story = successStories[index]
            story = SuccessStory(
                id: story.id,
                publishedHabitId: story.publishedHabitId,
                authorUsername: story.authorUsername,
                authorAvatar: story.authorAvatar,
                remissionStatus: story.remissionStatus,
                remissionDuration: story.remissionDuration,
                strategy: story.strategy,
                keyChanges: story.keyChanges,
                likes: story.likes + 1,
                xpEarned: story.xpEarned,
                starRating: story.starRating,
                adoptionCount: story.adoptionCount,
                publishedAt: story.publishedAt
            )
            successStories[index] = story
            saveSuccessStories()
            
            // Update the published habit rating
            HabitsManager.shared.rateHabit(story.publishedHabitId, isHelpful: true)
        }
    }
    
    func adoptStory(_ storyId: UUID) {
        if let index = successStories.firstIndex(where: { $0.id == storyId }) {
            var story = successStories[index]
            story = SuccessStory(
                id: story.id,
                publishedHabitId: story.publishedHabitId,
                authorUsername: story.authorUsername,
                authorAvatar: story.authorAvatar,
                remissionStatus: story.remissionStatus,
                remissionDuration: story.remissionDuration,
                strategy: story.strategy,
                keyChanges: story.keyChanges,
                likes: story.likes,
                xpEarned: story.xpEarned,
                starRating: story.starRating,
                adoptionCount: story.adoptionCount + 1,
                publishedAt: story.publishedAt
            )
            successStories[index] = story
            saveSuccessStories()
            
            // Award XP for viewing success stories
            DailyGoalsManager.shared.awardXP(50)
        }
    }
    
    // MARK: - Default Modules Initialization
    
    private func initializeDefaultModules() {
        if modules.isEmpty {
            let module1Id = UUID()
            let module2Id = UUID()
            let module3Id = UUID()
            let module4Id = UUID()
            
            modules = [
                LearningModule(
                    id: module1Id,
                    title: "Understanding Type 2 Diabetes",
                    description: "Learn the fundamentals of type 2 diabetes",
                    icon: "checkmark.circle.fill",
                    lessons: [
                        Lesson(
                            title: "What is Type 2 Diabetes?",
                            content: "Type 2 diabetes is a chronic metabolic condition where your body becomes resistant to insulin or doesn't produce enough insulin to maintain normal blood sugar levels. Unlike type 1 diabetes (an autoimmune condition), type 2 diabetes is largely preventable and often reversible through lifestyle changes.\n\nWhen you eat, your body breaks down carbohydrates into glucose (sugar), which enters your bloodstream. Insulin, produced by your pancreas, acts like a key that unlocks your cells to allow glucose to enter and be used for energy. In type 2 diabetes, this process breaks down.\n\nThe good news? Research shows that type 2 diabetes can often be reversed through diet, exercise, and weight loss. Many people have achieved remission, meaning their blood sugar returns to normal levels without medication.",
                            duration: 5,
                            order: 1,
                            keyPoints: [
                                "Type 2 diabetes is a metabolic condition, not a life sentence",
                                "It's characterized by insulin resistance or insufficient insulin production",
                                "Unlike type 1, it's largely preventable and often reversible",
                                "Lifestyle changes can lead to remission in many cases"
                            ],
                            tips: [
                                "Focus on whole, unprocessed foods",
                                "Reduce refined carbohydrates and added sugars",
                                "Aim for 7-9 hours of quality sleep nightly",
                                "Manage stress through meditation or exercise"
                            ],
                            facts: [
                                "Over 90% of diabetes cases are type 2",
                                "Even a 5-10% weight loss can significantly improve blood sugar",
                                "Regular exercise can improve insulin sensitivity within days",
                                "Many people achieve remission within 6-12 months of lifestyle changes"
                            ]
                        ),
                        Lesson(
                            title: "How Insulin Works",
                            content: "Insulin is a powerful hormone produced by beta cells in your pancreas. Think of it as a master key that unlocks your cells, allowing glucose (sugar) from your bloodstream to enter and be converted into energy.\n\nHere's how it works: When you eat, especially carbohydrates, your blood sugar rises. Your pancreas detects this increase and releases insulin into your bloodstream. Insulin then binds to receptors on your cells (especially muscle, fat, and liver cells), signaling them to open up and absorb glucose.\n\nIn healthy individuals, this process happens smoothly. But in type 2 diabetes, your cells become resistant to insulin's signals. They don't respond as well, so glucose stays in your bloodstream, leading to high blood sugar levels.\n\nThe exciting part? You can improve your insulin sensitivity through lifestyle changes. Exercise, especially strength training and high-intensity interval training, makes your cells more responsive to insulin. A low-carb or Mediterranean diet can also significantly improve insulin sensitivity.",
                            duration: 5,
                            order: 2,
                            keyPoints: [
                                "Insulin is a hormone that helps glucose enter cells",
                                "It acts like a key that unlocks cells for glucose",
                                "Insulin resistance means cells don't respond well to insulin",
                                "Lifestyle changes can dramatically improve insulin sensitivity"
                            ],
                            tips: [
                                "Exercise regularly - even 15 minutes helps",
                                "Eat protein with every meal to stabilize blood sugar",
                                "Avoid sugary drinks and refined carbs",
                                "Consider intermittent fasting to improve insulin sensitivity"
                            ],
                            facts: [
                                "A single workout can improve insulin sensitivity for up to 48 hours",
                                "Muscle is the largest consumer of glucose in your body",
                                "Sleep deprivation can reduce insulin sensitivity by 30%",
                                "Omega-3 fatty acids can improve insulin sensitivity"
                            ]
                        ),
                        Lesson(
                            title: "The Role of Blood Sugar",
                            content: "Blood sugar, or blood glucose, is the amount of sugar circulating in your bloodstream at any given time. It's your body's primary source of energy, powering everything from brain function to muscle movement.\n\nNormal blood sugar levels are tightly regulated between 70-100 mg/dL when fasting and below 140 mg/dL two hours after eating. Your body maintains this balance through a complex system involving insulin (which lowers blood sugar) and glucagon (which raises it).\n\nWhen blood sugar is consistently elevated (above 126 mg/dL fasting or 200 mg/dL after meals), you're in diabetic range. This happens because glucose can't enter cells effectively, so it accumulates in your bloodstream.\n\nHigh blood sugar over time damages blood vessels, nerves, and organs. But here's the empowering truth: by managing your blood sugar through diet, exercise, and lifestyle changes, you can prevent complications and even reverse diabetes. Monitoring your blood sugar helps you understand how different foods, activities, and habits affect your body.",
                            duration: 5,
                            order: 3,
                            keyPoints: [
                                "Blood sugar is your body's primary energy source",
                                "Normal fasting levels are 70-100 mg/dL",
                                "Consistently high levels indicate diabetes",
                                "You can manage blood sugar through lifestyle changes"
                            ],
                            tips: [
                                "Test your blood sugar to learn what affects you",
                                "Eat meals with protein, fat, and fiber together",
                                "Take a 10-minute walk after meals",
                                "Stay hydrated - dehydration can raise blood sugar"
                            ],
                            facts: [
                                "Your brain uses about 20% of your body's glucose",
                                "Stress hormones can raise blood sugar even without eating",
                                "Cinnamon may help improve blood sugar control",
                                "Regular monitoring helps identify patterns and triggers"
                            ]
                        ),
                        Lesson(
                            title: "Insulin Resistance Explained",
                            content: "Insulin resistance is the root cause of type 2 diabetes. It occurs when your cells become less responsive to insulin's signals, requiring more and more insulin to move glucose from your bloodstream into cells.\n\nThink of it like this: Imagine insulin is a key and your cells are locks. In insulin resistance, the locks become rusty and harder to open. Your pancreas works overtime, producing more insulin to force the locks open. Eventually, your pancreas can't keep up, and blood sugar rises.\n\nWhat causes insulin resistance? Excess body fat, especially around the abdomen, is a major factor. Fat cells release inflammatory chemicals that interfere with insulin signaling. Sedentary lifestyle, poor diet (especially high in refined carbs and sugar), chronic stress, and inadequate sleep all contribute.\n\nThe incredible news? Insulin resistance is reversible. Studies show that losing just 5-10% of body weight can dramatically improve insulin sensitivity. Regular exercise, especially resistance training, makes your muscle cells more insulin-sensitive. A low-carb or Mediterranean diet reduces the demand for insulin, giving your system a break.",
                            duration: 5,
                            order: 4,
                            keyPoints: [
                                "Insulin resistance is when cells don't respond well to insulin",
                                "It's the root cause of type 2 diabetes",
                                "Excess body fat is a major contributing factor",
                                "It's reversible through lifestyle changes"
                            ],
                            tips: [
                                "Lose 5-10% of body weight to improve insulin sensitivity",
                                "Build muscle through strength training",
                                "Reduce refined carbohydrates and added sugars",
                                "Get 7-9 hours of quality sleep nightly"
                            ],
                            facts: [
                                "Muscle is more insulin-sensitive than fat tissue",
                                "Even one week of overeating can reduce insulin sensitivity",
                                "Resistance training improves insulin sensitivity for 24-48 hours",
                                "Intermittent fasting can improve insulin sensitivity within weeks"
                            ]
                        ),
                        Lesson(
                            title: "Risk Factors and Prevention",
                            content: "Understanding your risk factors for type 2 diabetes empowers you to take preventive action. While some factors like genetics and age are beyond your control, many are modifiable through lifestyle changes.\n\nMajor risk factors include:\n• Excess weight, especially abdominal fat\n• Sedentary lifestyle\n• Poor diet (high in processed foods, sugar, refined carbs)\n• Family history of diabetes\n• Age (risk increases after 45)\n• Prediabetes (blood sugar higher than normal but not yet diabetic)\n• Gestational diabetes during pregnancy\n• Polycystic ovary syndrome (PCOS)\n• High blood pressure or cholesterol\n\nThe powerful truth? Even if you have multiple risk factors, you can significantly reduce your risk or reverse prediabetes/diabetes through lifestyle changes. Research shows that people with prediabetes who lose 5-7% of body weight and exercise 150 minutes per week reduce their diabetes risk by 58%.\n\nPrevention strategies include maintaining a healthy weight, eating a balanced diet rich in whole foods, staying physically active, managing stress, getting adequate sleep, and avoiding smoking. The earlier you act, the better your outcomes.",
                            duration: 5,
                            order: 5,
                            keyPoints: [
                                "Many risk factors are modifiable through lifestyle",
                                "Excess weight and inactivity are major risk factors",
                                "Prediabetes can be reversed before it becomes diabetes",
                                "Early action dramatically improves outcomes"
                            ],
                            tips: [
                                "Get regular health screenings if you have risk factors",
                                "Aim for 150 minutes of exercise per week",
                                "Focus on whole foods and limit processed foods",
                                "Build a support system for accountability"
                            ],
                            facts: [
                                "People with prediabetes can reduce diabetes risk by 58%",
                                "Losing just 5-7% of body weight can prevent diabetes",
                                "Regular exercise reduces diabetes risk by 40%",
                                "A Mediterranean diet can reduce diabetes risk by 30%"
                            ]
                        )
                    ],
                    xpReward: 100,
                    order: 1
                ),
                LearningModule(
                    id: module2Id,
                    title: "Nutrition & Diet Basics",
                    description: "Master the fundamentals of diabetes-friendly nutrition",
                    icon: "book.fill",
                    lessons: [
                        Lesson(
                            title: "Carbs & Blood Sugar",
                            content: "Carbohydrates have the most significant impact on your blood sugar levels. Understanding how different carbs affect you is crucial for diabetes management and reversal.\n\nNot all carbohydrates are created equal. Simple carbs (sugar, white bread, white rice) are quickly broken down into glucose, causing rapid blood sugar spikes. Complex carbs (whole grains, vegetables, legumes) are digested more slowly, leading to gradual blood sugar increases.\n\nFiber is your friend! Foods high in fiber slow down carbohydrate digestion and absorption, preventing blood sugar spikes. Aim for 25-35 grams of fiber daily from vegetables, fruits, whole grains, and legumes.\n\nNet carbs (total carbs minus fiber) give you a better picture of a food's blood sugar impact. For diabetes reversal, many people find success with low-carb or very low-carb diets (under 50-100g net carbs per day).\n\nRemember: You don't have to eliminate carbs entirely. Focus on quality carbs from whole foods, pair them with protein and healthy fats, and monitor how your body responds.",
                            duration: 6,
                            order: 1,
                            keyPoints: [
                                "Carbs have the biggest impact on blood sugar",
                                "Simple carbs spike blood sugar quickly",
                                "Fiber slows carbohydrate absorption",
                                "Quality and quantity both matter"
                            ],
                            tips: [
                                "Choose whole grains over refined grains",
                                "Pair carbs with protein and healthy fats",
                                "Aim for 25-35g of fiber daily",
                                "Monitor your blood sugar after meals"
                            ],
                            facts: [
                                "Fiber doesn't raise blood sugar",
                                "Net carbs = total carbs - fiber",
                                "Low-carb diets can reverse diabetes in many people",
                                "Eating carbs with protein reduces blood sugar spikes"
                            ]
                        ),
                        Lesson(
                            title: "Understanding Glycemic Index",
                            content: "The Glycemic Index (GI) is a scale from 0-100 that ranks foods by how quickly they raise blood sugar. Understanding GI helps you make smarter food choices.\n\nHigh GI foods (70+) cause rapid blood sugar spikes. Examples include white bread, white rice, potatoes, and sugary drinks. Medium GI foods (56-69) cause moderate increases, like whole wheat bread and brown rice. Low GI foods (55 or less) cause gradual blood sugar rises, such as most vegetables, legumes, and whole grains.\n\nHowever, GI isn't the whole story. Glycemic Load (GL) considers both the GI and the amount of carbs in a serving. A food can have a high GI but low GL if the serving size is small.\n\nFor diabetes reversal, focus on low-GI foods most of the time. But remember: how you prepare and combine foods matters. Adding protein, fat, or fiber to a meal lowers its overall glycemic impact. Cooking methods also affect GI - al dente pasta has a lower GI than overcooked pasta.",
                            duration: 6,
                            order: 2,
                            keyPoints: [
                                "GI measures how quickly foods raise blood sugar",
                                "Low GI foods cause gradual blood sugar rises",
                                "Glycemic Load considers both GI and portion size",
                                "Food combinations affect glycemic impact"
                            ],
                            tips: [
                                "Choose low-GI foods most of the time",
                                "Add protein, fat, or fiber to meals",
                                "Don't overcook starchy foods",
                                "Use GI as a guide, not a strict rule"
                            ],
                            facts: [
                                "Most vegetables have a very low GI",
                                "Fat and protein lower a meal's glycemic impact",
                                "Ripeness affects GI (riper fruit = higher GI)",
                                "Acid (like vinegar) can lower GI"
                            ]
                        ),
                        Lesson(
                            title: "Protein & Fat Benefits",
                            content: "Protein and healthy fats are powerful allies in diabetes management and reversal. Unlike carbohydrates, they have minimal impact on blood sugar and provide numerous metabolic benefits.\n\nProtein helps stabilize blood sugar in several ways. It slows down carbohydrate digestion, preventing blood sugar spikes. It also promotes satiety, helping you eat less overall. Protein requires more energy to digest (thermic effect), boosting metabolism. Most importantly, it helps preserve and build muscle mass, which is crucial since muscle is highly insulin-sensitive.\n\nHealthy fats (monounsaturated and polyunsaturated) improve insulin sensitivity, reduce inflammation, and provide sustained energy. They also help you absorb fat-soluble vitamins and keep you feeling full longer.\n\nAim for 0.8-1g of protein per pound of body weight daily, distributed across meals. Include healthy fats from sources like avocados, nuts, seeds, olive oil, and fatty fish. Avoid trans fats and limit saturated fats from processed foods.",
                            duration: 6,
                            order: 3,
                            keyPoints: [
                                "Protein stabilizes blood sugar and promotes satiety",
                                "Healthy fats improve insulin sensitivity",
                                "Both have minimal impact on blood sugar",
                                "They're essential for diabetes reversal"
                            ],
                            tips: [
                                "Include protein with every meal",
                                "Choose lean proteins and plant-based options",
                                "Add healthy fats like avocado and nuts",
                                "Avoid trans fats completely"
                            ],
                            facts: [
                                "Protein has a thermic effect, boosting metabolism",
                                "Omega-3 fats can improve insulin sensitivity",
                                "Muscle is more insulin-sensitive than fat",
                                "Healthy fats don't raise blood sugar"
                            ]
                        ),
                        Lesson(
                            title: "Meal Planning Strategies",
                            content: "Effective meal planning is the foundation of successful diabetes management and reversal. A well-planned approach takes the guesswork out of eating and helps you maintain stable blood sugar.\n\nThe plate method is a simple visual guide: Fill half your plate with non-starchy vegetables (broccoli, spinach, peppers), one-quarter with lean protein (chicken, fish, tofu), and one-quarter with quality carbs (quinoa, sweet potato) or healthy fats.\n\nMeal timing matters. Eating at consistent times helps regulate blood sugar. Some people benefit from intermittent fasting (eating within an 8-10 hour window), which can improve insulin sensitivity.\n\nBatch cooking and meal prep save time and ensure you always have healthy options. Prepare proteins, vegetables, and healthy snacks in advance. Keep healthy options visible and accessible.\n\nRemember: There's no one-size-fits-all approach. Experiment to find what works for your body, schedule, and preferences. Monitor your blood sugar to see how different meal patterns affect you.",
                            duration: 6,
                            order: 4,
                            keyPoints: [
                                "Meal planning removes guesswork",
                                "The plate method is a simple visual guide",
                                "Consistent meal timing helps regulate blood sugar",
                                "Preparation is key to success"
                            ],
                            tips: [
                                "Use the plate method for balanced meals",
                                "Prep meals and snacks in advance",
                                "Eat at consistent times daily",
                                "Keep healthy options visible and accessible"
                            ],
                            facts: [
                                "Meal prep can save 2-3 hours per week",
                                "Eating protein first can reduce blood sugar spikes",
                                "Intermittent fasting can improve insulin sensitivity",
                                "Consistent meal timing helps regulate circadian rhythms"
                            ]
                        ),
                        Lesson(
                            title: "Portion Control",
                            content: "Understanding portion sizes is crucial for managing blood sugar, even when eating healthy foods. Too much of even healthy foods can raise blood sugar.\n\nVisual cues help: A serving of protein is about the size of your palm. A serving of carbs is about the size of your fist. A serving of fat is about the size of your thumb. Vegetables? Fill up - most are very low in calories and carbs.\n\nUse smaller plates to make portions look larger. Eat slowly and mindfully - it takes 20 minutes for your brain to register fullness. Stop eating when you're 80% full.\n\nFor diabetes reversal, many people find success with lower-carb approaches, which naturally reduce portion sizes of carb-heavy foods. Focus on filling up on vegetables and protein, with smaller portions of starchy carbs.\n\nRemember: Portion control isn't about deprivation. It's about eating the right amounts of the right foods to fuel your body optimally.",
                            duration: 6,
                            order: 5,
                            keyPoints: [
                                "Portion size affects blood sugar, even for healthy foods",
                                "Visual cues help estimate portions",
                                "Eating slowly helps recognize fullness",
                                "Focus on vegetables and protein"
                            ],
                            tips: [
                                "Use your hand as a portion guide",
                                "Use smaller plates",
                                "Eat slowly and mindfully",
                                "Stop when 80% full"
                            ],
                            facts: [
                                "It takes 20 minutes to feel full",
                                "Larger plates make portions look smaller",
                                "Protein and fiber increase satiety",
                                "Portion control is more important than calorie counting for many"
                            ]
                        ),
                        Lesson(
                            title: "Reading Food Labels",
                            content: "Reading food labels empowers you to make informed choices that support diabetes reversal. Understanding what to look for helps you avoid hidden sugars and make better decisions.\n\nStart with the serving size - all information on the label is based on this. Many packages contain multiple servings, so multiply if you eat more.\n\nCheck total carbohydrates, but pay attention to fiber and sugar. Net carbs (total carbs minus fiber) give you a better picture. Look for foods with high fiber and low sugar.\n\nIngredients are listed by weight, so the first few ingredients matter most. Avoid products where sugar (or its many names) appears in the first three ingredients. Watch for hidden sugars: high-fructose corn syrup, cane sugar, dextrose, maltose, and many others.\n\nLook for whole foods with short ingredient lists. Generally, if you can't pronounce it or don't know what it is, it's probably not supporting your health goals.",
                            duration: 6,
                            order: 6,
                            keyPoints: [
                                "Serving size affects all label information",
                                "Net carbs = total carbs - fiber",
                                "Ingredients are listed by weight",
                                "Short ingredient lists are usually better"
                            ],
                            tips: [
                                "Always check serving size first",
                                "Calculate net carbs (total - fiber)",
                                "Avoid products with sugar in first 3 ingredients",
                                "Choose whole foods with short ingredient lists"
                            ],
                            facts: [
                                "Sugar has over 60 different names on labels",
                                "Fiber doesn't raise blood sugar",
                                "Net carbs give a better picture than total carbs",
                                "Many 'healthy' foods contain hidden sugars"
                            ]
                        )
                    ],
                    xpReward: 120,
                    order: 2
                ),
                LearningModule(
                    id: module3Id,
                    title: "Exercise & Movement",
                    description: "Discover how physical activity supports diabetes reversal",
                    icon: "book.fill",
                    lessons: [
                        Lesson(
                            title: "Why Exercise Matters",
                            content: "Exercise is one of the most powerful tools for diabetes reversal. It works in multiple ways to improve your metabolic health.\n\nFirst, exercise makes your cells more insulin-sensitive. When you exercise, your muscles need energy, so they become more receptive to insulin, allowing glucose to enter more easily. This effect can last for 24-48 hours after a single workout.\n\nExercise also helps you burn glucose directly. During physical activity, your muscles use glucose for energy, lowering blood sugar. This is why a 15-minute walk after a meal can significantly reduce post-meal blood sugar spikes.\n\nRegular exercise helps you lose weight and build muscle. Since muscle is highly insulin-sensitive, having more muscle mass improves your overall insulin sensitivity. Exercise also reduces inflammation, which is linked to insulin resistance.\n\nThe best part? You don't need to become a gym rat. Even moderate activity like walking, gardening, or dancing can provide significant benefits. The key is consistency.",
                            duration: 5,
                            order: 1,
                            keyPoints: [
                                "Exercise improves insulin sensitivity",
                                "It helps burn glucose directly",
                                "Building muscle increases insulin sensitivity",
                                "Consistency matters more than intensity"
                            ],
                            tips: [
                                "Start with activities you enjoy",
                                "Aim for 150 minutes per week",
                                "Take a 10-15 minute walk after meals",
                                "Mix cardio and strength training"
                            ],
                            facts: [
                                "A single workout improves insulin sensitivity for 24-48 hours",
                                "Post-meal walks can reduce blood sugar by 20-30%",
                                "Muscle is more insulin-sensitive than fat",
                                "Even 10 minutes of activity helps"
                            ]
                        ),
                        Lesson(
                            title: "Types of Exercise",
                            content: "Different types of exercise offer unique benefits for diabetes management and reversal. A well-rounded approach combines multiple types.\n\nAerobic exercise (walking, jogging, cycling, swimming) improves cardiovascular health and helps burn calories and glucose. It's excellent for improving insulin sensitivity and lowering blood sugar. Aim for moderate intensity where you can still hold a conversation.\n\nStrength training (weight lifting, resistance bands, bodyweight exercises) is particularly powerful for diabetes. It builds muscle mass, which is highly insulin-sensitive. More muscle means better blood sugar control. Strength training also improves insulin sensitivity for hours after your workout.\n\nHigh-intensity interval training (HIIT) involves short bursts of intense activity followed by recovery. It's time-efficient and highly effective for improving insulin sensitivity and burning glucose.\n\nFlexibility and balance exercises (yoga, tai chi) reduce stress, improve mobility, and can help with blood sugar control. Find activities you enjoy and mix them up for the best results.",
                            duration: 5,
                            order: 2,
                            keyPoints: [
                                "Aerobic exercise improves cardiovascular health",
                                "Strength training builds insulin-sensitive muscle",
                                "HIIT is time-efficient and effective",
                                "A combination works best"
                            ],
                            tips: [
                                "Include both cardio and strength training",
                                "Try HIIT for time-efficient workouts",
                                "Add yoga or stretching for flexibility",
                                "Find activities you enjoy"
                            ],
                            facts: [
                                "Strength training improves insulin sensitivity for hours",
                                "HIIT can be more effective than steady-state cardio",
                                "Yoga can reduce stress and improve blood sugar",
                                "Variety prevents boredom and plateaus"
                            ]
                        ),
                        Lesson(
                            title: "Starting Safely",
                            content: "Starting an exercise program safely is crucial, especially if you've been inactive or have diabetes complications. Taking the right precautions ensures you can exercise effectively without risk.\n\nFirst, consult your healthcare provider, especially if you have complications like neuropathy, retinopathy, or cardiovascular issues. They can help you determine safe exercise parameters.\n\nStart slowly and gradually increase intensity and duration. The '10% rule' is helpful: increase your activity by no more than 10% per week. If you're walking 10 minutes, add 1 minute the next week.\n\nMonitor your blood sugar before, during, and after exercise, especially when starting. Exercise can lower blood sugar, so you may need to adjust medication or eat a snack beforehand. Keep glucose tablets or a snack handy.\n\nWear proper footwear, especially if you have neuropathy. Check your feet daily for blisters or sores. Stay hydrated and listen to your body. If something hurts, stop and rest.",
                            duration: 5,
                            order: 3,
                            keyPoints: [
                                "Consult your healthcare provider first",
                                "Start slowly and progress gradually",
                                "Monitor blood sugar during exercise",
                                "Take proper safety precautions"
                            ],
                            tips: [
                                "Increase activity by 10% per week",
                                "Check blood sugar before and after exercise",
                                "Keep a snack handy for low blood sugar",
                                "Wear proper footwear and check feet daily"
                            ],
                            facts: [
                                "Exercise can lower blood sugar during and after",
                                "Proper footwear prevents foot complications",
                                "Gradual progression prevents injury",
                                "Most people can exercise safely with diabetes"
                            ]
                        ),
                        Lesson(
                            title: "Building a Routine",
                            content: "Consistency is the key to reaping exercise benefits for diabetes reversal. Building a sustainable routine that fits your life is more important than perfect workouts.\n\nStart with realistic goals. If you're new to exercise, aim for 10-15 minutes, 3 times per week. As you build the habit, gradually increase frequency, duration, and intensity. The goal is 150 minutes of moderate activity per week, but you can work up to this.\n\nSchedule exercise like any other appointment. Put it in your calendar and treat it as non-negotiable. Morning workouts are often easier to stick with because there are fewer distractions.\n\nFind activities you enjoy. If you hate running, don't run. Try dancing, swimming, hiking, or group fitness classes. Enjoyment increases adherence.\n\nBuild accountability. Exercise with a friend, join a class, or use an app to track your progress. Celebrate small wins - every workout counts. Remember: something is always better than nothing.",
                            duration: 5,
                            order: 4,
                            keyPoints: [
                                "Consistency matters more than perfection",
                                "Start with realistic, achievable goals",
                                "Schedule exercise like an appointment",
                                "Find activities you enjoy"
                            ],
                            tips: [
                                "Start with 10-15 minutes, 3x per week",
                                "Schedule workouts in your calendar",
                                "Exercise with a friend for accountability",
                                "Celebrate every workout as a win"
                            ],
                            facts: [
                                "It takes 2-3 months to form a habit",
                                "Morning exercisers are more consistent",
                                "Social support increases adherence by 50%",
                                "Even 10 minutes provides benefits"
                            ]
                        )
                    ],
                    xpReward: 80,
                    order: 3
                ),
                LearningModule(
                    id: module4Id,
                    title: "Advanced Reversal Strategies",
                    description: "Advanced techniques for diabetes reversal",
                    icon: "lock.fill",
                    lessons: [
                        Lesson(title: "Intermittent Fasting", content: "Intermittent fasting can improve insulin sensitivity...", duration: 7, order: 1),
                        Lesson(title: "Stress Management", content: "Chronic stress affects blood sugar levels...", duration: 7, order: 2),
                        Lesson(title: "Sleep Optimization", content: "Quality sleep is essential for metabolic health...", duration: 7, order: 3),
                        Lesson(title: "Supplement Strategies", content: "Certain supplements may support diabetes reversal...", duration: 7, order: 4),
                        Lesson(title: "Monitoring Progress", content: "Track your progress with key metrics...", duration: 7, order: 5),
                        Lesson(title: "Long-term Maintenance", content: "Maintaining remission requires ongoing commitment...", duration: 7, order: 6),
                        Lesson(title: "Troubleshooting Challenges", content: "Learn to overcome common obstacles...", duration: 7, order: 7)
                    ],
                    xpReward: 150,
                    isLocked: true,
                    unlockRequirement: "Complete previous modules to unlock",
                    order: 4
                )
            ]
            saveModules()
            initializeDefaultTests()
        }
    }
    
    // MARK: - Default Tests Initialization
    
    private func initializeDefaultTests() {
        // Only create tests if they don't exist
        guard tests.isEmpty else { return }
        
        // Test for "Understanding Type 2 Diabetes" module
        if let module1 = modules.first(where: { $0.title == "Understanding Type 2 Diabetes" }) {
            let test1 = Test(
                moduleId: module1.id,
                questions: [
                    Question(
                        text: "WHAT IS TYPE 2 DIABETES?",
                        options: [
                            "A condition where the body doesn't produce any insulin",
                            "A condition where cells become resistant to insulin",
                            "A temporary increase in blood sugar",
                            "A genetic disease that cannot be reversed"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Type 2 diabetes occurs when your cells become resistant to insulin, making it harder for glucose to enter cells. This can often be reversed through lifestyle changes."
                    ),
                    Question(
                        text: "HOW DOES INSULIN WORK IN THE BODY?",
                        options: [
                            "Insulin breaks down glucose into energy",
                            "Insulin helps glucose enter cells for energy",
                            "Insulin removes glucose from the bloodstream",
                            "Insulin converts glucose into fat"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Insulin is a hormone that helps glucose enter your cells, where it can be used for energy."
                    ),
                    Question(
                        text: "WHAT IS INSULIN RESISTANCE?",
                        options: [
                            "The pancreas stops producing insulin",
                            "Cells don't respond properly to insulin",
                            "Too much insulin in the bloodstream",
                            "Insulin is broken down too quickly"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Insulin resistance means your cells don't respond properly to insulin, requiring more insulin to move glucose into cells."
                    ),
                    Question(
                        text: "CAN TYPE 2 DIABETES BE REVERSED?",
                        options: [
                            "No, it's a permanent condition",
                            "Yes, through lifestyle changes like diet and exercise",
                            "Only with medication",
                            "Only through surgery"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Type 2 diabetes can often be reversed through lifestyle changes including diet, exercise, and weight loss."
                    ),
                    Question(
                        text: "WHAT IS THE PRIMARY RISK FACTOR FOR TYPE 2 DIABETES?",
                        options: [
                            "Age only",
                            "Genetics only",
                            "Lifestyle factors like poor diet and lack of exercise",
                            "Viral infections"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "Lifestyle factors like poor diet, lack of exercise, and excess weight are primary risk factors for type 2 diabetes."
                    )
                ]
            )
            tests.append(test1)
        }
        
        // Add more tests for other modules as needed
        saveTests()
    }
    
    func getTestQuestions(for moduleId: UUID) -> [Question]? {
        return tests.first(where: { $0.moduleId == moduleId })?.questions
    }
    
    // MARK: - Persistence
    
    private func saveModules() {
        if let encoded = try? JSONEncoder().encode(modules) {
            UserDefaults.standard.set(encoded, forKey: modulesKey)
        }
    }
    
    private func loadModules() {
        if let data = UserDefaults.standard.data(forKey: modulesKey),
           let decoded = try? JSONDecoder().decode([LearningModule].self, from: data) {
            modules = decoded
        }
    }
    
    private func saveTests() {
        if let encoded = try? JSONEncoder().encode(tests) {
            UserDefaults.standard.set(encoded, forKey: testsKey)
        }
    }
    
    private func loadTests() {
        if let data = UserDefaults.standard.data(forKey: testsKey),
           let decoded = try? JSONDecoder().decode([Test].self, from: data) {
            tests = decoded
        }
    }
    
    private func saveSuccessStories() {
        if let encoded = try? JSONEncoder().encode(successStories) {
            UserDefaults.standard.set(encoded, forKey: storiesKey)
        }
    }
    
    private func loadSuccessStories() {
        if let data = UserDefaults.standard.data(forKey: storiesKey),
           let decoded = try? JSONDecoder().decode([SuccessStory].self, from: data) {
            successStories = decoded
        }
    }
}

