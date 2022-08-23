//
//  PinboardMockService.swift
//  ThesisApp
//
//  Created by Lisa Wittmann on 19.08.22.
//

import Foundation
import Combine

extension PinboardMockService: PinboardService {
    
    func setVersionToken(_ versionToken: String?) {
        self.versionToken = versionToken
    }
    
    func importPostings() -> AnyPublisher<ListData<PostingResponseData>, HttpError> {
        return Just(ListData<PostingResponseData>(
                data: postings,
                versionToken: versionToken
            ))
            .setFailureType(to: HttpError.self)
            .eraseToAnyPublisher()
    }
    
    func createPosting(_ posting: PostingRequestData) -> AnyPublisher<PostingResponseData, HttpError> {
        return Just(.init(
                id: Int64(self.postings.count + 1),
                headline: posting.headline,
                content: posting.content,
                creationDate: .now,
                userName: "Max M",
                userId: 0,
                keywords: [],
                comments: []
            ))
            .setFailureType(to: HttpError.self)
            .eraseToAnyPublisher()
    }
    
    func createComment(_ comment: String, for posting: Posting) -> AnyPublisher<PostingResponseData, HttpError> {
        guard var storedPosting = postings.filter({ $0.id == posting.id }).first else {
            return AnyPublisher(
                Fail<PostingResponseData, HttpError>(error: HttpError.invalidData)
            )
        }
        
        storedPosting.comments.append(CommentResponseData(
            id: 10,
            content: comment,
            creationDate: .now,
            userName: "Max M",
            userId: 0
        ))
        
        return Just(storedPosting)
            .setFailureType(to: HttpError.self)
            .eraseToAnyPublisher()
    }
}

class PinboardMockService {
    
    var versionToken: String? = nil
    
    private let postings: [PostingResponseData] = [
        .init(
            id: 0,
            headline: "Mitfahrgelegenheit nach FFM",
            content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim.",
            creationDate: .now,
            userName: "Justus B",
            userId: 1,
            keywords: [Keyword.transport.rawValue],
            comments: []
        ),
        .init(
            id: 1,
            headline: "Joggingpartner gesucht",
            content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim.",
            creationDate: .now,
            userName: "Michaela W",
            userId: 2,
            keywords: [Keyword.need.rawValue],
            comments: []
        ),
        .init(
            id: 2,
            headline: "Grillparty im Hof am Samstag",
            content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim.",
            creationDate: .now,
            userName: "Martin K",
            userId: 3,
            keywords: [Keyword.party.rawValue, Keyword.food.rawValue, Keyword.event.rawValue],
            comments: [
                .init(
                    id: 0,
                    content: "Super Idee, ich freue mich! Soll ich Getränke mitbringen?",
                    creationDate: .now,
                    userName: "Anja M",
                    userId: 4
                ),
                .init(
                    id: 1,
                    content: "Hi Anja, bring doch deine selbstgemacht Bowle vom letzten Mal wieder mit?",
                    creationDate: .now,
                    userName: "Martin K",
                    userId: 3
                )
            ]
        ),
    ]
}
