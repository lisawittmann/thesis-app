//
//  Comment.swift
//  thesis-app
//
//  Created by Lisa Wittmann on 12.07.22.
//

import CoreData

@objc(Comment)
public class Comment: NSManagedObject {
    
    fileprivate(set) var content: String {
        get { content_! }
        set { content_ = newValue}
    }
    fileprivate(set) var creator: User {
        get { creator_! }
        set { creator_ = newValue }
    }
    
    fileprivate(set) var creationDate: Date {
        get { creationDate_! }
        set { creationDate_ = newValue.formatted ?? newValue }
    }
    
    fileprivate(set) var posting: Posting {
        get { posting_! }
        set { posting_ = newValue }
    }
}

extension Comment: Comparable {
    
    public static func < (lhs: Comment, rhs: Comment) -> Bool {
        lhs.creationDate < rhs.creationDate
    }
}

extension Comment {
    
    static func fetchRequest(_ predicate: NSPredicate? = nil) -> NSFetchRequest<Comment> {
        let request = NSFetchRequest<Comment>(entityName: "Comment")
        request.sortDescriptors = [NSSortDescriptor(
            key: "creationDate_",
            ascending: true
        )]
        request.predicate = predicate
        return request
    }
}

extension Comment {
    
    convenience init(
        with data: CommentResponseData,
        for posting: Posting,
        by creator: User,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.id = data.id
        self.content = data.content
        self.creationDate = data.creationDate
        self.creator = creator
        self.posting = posting
    }
    
    func isCreator(_ userId: Int) -> Bool {
        creator.id == Int64(userId)
    }
}

extension PersistenceController {
    
    func getComment(with data: CommentResponseData, for posting: Posting) -> Comment {
        let request = Comment.fetchRequest(NSPredicate(format: "id == %i", data.id))
        
        let creator = getUser(with: data.creator)
        
        if let comment = try? container.viewContext.fetch(request).first {
            print("found existing comment: \(comment.content)")
            comment.content = data.content
            try? container.viewContext.save()
            return comment
        }
        
        let comment = Comment(with: data, for: posting, by: creator, in: container.viewContext)
        do {
            try container.viewContext.save()
            print("saved new comment: \(comment.content)")
        } catch {
            print(error)
            print("failed on comment: \(comment.content)")
        }
        return comment
    }
    
    func deleteComment(with data: CommentResponseData) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
        deleteFetch.predicate = NSPredicate(format: "id == %i", data.id)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        _ = try? container.viewContext.execute(deleteRequest)
        try? container.viewContext.save()
    }
    
    func delete(_ comment: Comment) {
        do {
            container.viewContext.delete(comment as NSManagedObject)
            try container.viewContext.save()
        } catch {
            print("deleting comment failed")
            print(error)
        }
    }
}
