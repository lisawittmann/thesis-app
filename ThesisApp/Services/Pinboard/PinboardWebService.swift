//
//  PinboardWebService.swift
//  ThesisApp
//
//  Created by Lisa Wittmann on 19.08.22.
//

import Foundation
import Combine

class PinboardWebService: PinboardService {
    
    func importPostings() -> AnyPublisher<ListData<PostingResponseData>, HttpError> {
        guard let url = URL(string: Http.baseUrl + "/private/pinboard") else {
            return AnyPublisher(
                Fail<ListData<PostingResponseData>, HttpError>(error: .invalidUrl)
            )
        }
        
        guard let payload = try? Http.encoder.encode(SessionStorage.pinboardVersionToken) else {
            return AnyPublisher(
                Fail<ListData<PostingResponseData>, HttpError>(error: .invalidData)
            )
        }
        
        return Http.post(url, payload: payload, receive: ListData<PostingResponseData>.self)
    }
    
    
    func createPosting(_ posting: PostingRequestData) -> AnyPublisher<PostingResponseData, HttpError> {
        guard let url = URL(string: Http.baseUrl + "/private/pinboard/save") else {
            return AnyPublisher(
                Fail<PostingResponseData, HttpError>(error: .invalidUrl)
            )
        }
        
        guard let payload = try? Http.encoder.encode(posting) else {
            return AnyPublisher(
                Fail<PostingResponseData, HttpError>(error: .invalidData)
            )
        }
        
        return Http.post(url, payload: payload, receive: PostingResponseData.self)
    }
    
    
    func createComment(_ comment: CommentRequestData) -> AnyPublisher<PostingResponseData, HttpError> {
        guard let url = URL(string: Http.baseUrl + "/private/pinboard/comment") else {
            return AnyPublisher(
                Fail<PostingResponseData, HttpError>(error: HttpError.invalidUrl)
            )
        }
        
        guard let payload = try? Http.encoder.encode(comment) else {
            return AnyPublisher(
                Fail<PostingResponseData, HttpError>(error: HttpError.invalidData)
            )
        }
        
        return Http.post(url, payload: payload, receive: PostingResponseData.self)
    }
    
    
}
