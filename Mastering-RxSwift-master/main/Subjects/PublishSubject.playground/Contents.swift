//
//  Copyright (c) 2019 KxCoding <kky0317@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import RxSwift


// - 옵저버블은 이벤트를 전달한다.
// - 옵저버는 옵저버블을 구독하고 전달되는 이벤트를 처리한다.
// - 옵저버블은 옵저버와 달리 다른 옵저버블을 구독하지 못한다.
// - 옵저버는 다른 옵저버로 이벤트를 전달하지 못한다.

// - 반면 Subject는 다른 옵저버블로부터 이벤트를 받아서 구독자로 전달할 수 있다.
// - Subject는 옵저버블인 동시에 옵저버이다.

// Subject의 종류
// - PublichSubject : 서브젝트로 전달되는 새로운 이벤트를 구독자에게 전달한다.
// - BehaviorSubject : 생성 시점에 시작 이벤트를 지점. 서브젝트로 전달되는 이벤트중 가장 마지막 최신 이벤트를 저장하고, 새로운 구독자에세  최신 이벤트를 전달한다.
// - ReplaySubject : 하나 이상의 최신이벤트를 버퍼에 저장한다. 옵저버가 구독을 시작하면 버퍼에 있는 모든 이벤트를 전달한다.
// - AsyncSubject : 서브젝트로 Completed 이벤트가 전달되는 시점에 마지막으로 전달된 next이벤트를 구독자로 전달한다.

//rxswift는 Subject를 랩핑하고 있는 두 가지 Relay를 제공한다. 이전버전에선 variable이엿는데 대체됨.
// - PublishRelay : PublichSubject를 랩핑 한 것
// - BehaviorRelay : BehaviorSubject를 랩핑 한 것
// - 릴레이는 일반적인 서브젝트와 달리 next이벤트만 받고 나머지 Completed, Error이벤트는 받지 않음.
// - 주로 종료없이 계속 실행되는 이벤트 sequence를 처리할 때 활용됨
/*:
 # PublishSubject
 */

// 서브젝트로 전달되는 이벤트를 옵저버에게 전달하는 가장 기본적인 서브젝트.

let disposeBag = DisposeBag()

enum MyError: Error {
   case error
}


let subject = PublishSubject<String>()
// - 문자열이 포함된 넥스트 이벤트를 받아서 다른 옵저버에게 전달 가능.
// - 생성자를 전달할 때는 파라미터를 전달하지 않음. 내부에는 아무런 이벤트가 저장되어 있지 않다.
// - 그래서 생성 직후에 옵저버가 구독을 시작하면 아무 이벤트도 전달하지 않는다.

subject.onNext("Hello") //여기까지 하면 서브젝트를 구독하고 있는 옵저버가 없기 때문에 이벤트가 처리되지 않고 사라짐.

let o1 = subject.subscribe{ print(">> 1", $0) }
o1.disposed(by: disposeBag)

// 아무 것도 출력이 안된다 왜? PublishSubject는 구독 이후에 전달되는 새로운 이벤트만 전달 할 수 있다.
// 따라서 구독 전에 생성되었던 이벤트는 전달되지 않는다.

subject.onNext("RxSwift")

let o2 = subject.subscribe{ print(">> 2", $0) }
o2.disposed(by: disposeBag)

subject.onNext("Subject") // 두 구독자 모두 이 이벤트를 받음.
// subject.onCompleted() // 두 구독자 모두 completed 이벤트 받음.

subject.onError(MyError.error)

// 옵져버블에서 completed 이벤트가 전달된 이후에는 더이상 넥스트 이벤트가 전달되지 않음  = 서브젝트도 이부분은 옵저버블과 같다.
// 에러도 마찬가지
let o3 = subject.subscribe { print(">> 3", $0) }
o3.disposed(by: disposeBag)


// MARK: 정리 !!
// - PublishSubject은 이벤트가 전달되면 즉시 구독자에게 전달한다.
// - 그래서 서브젝트가 최초로 생성되는 시점과 첫번째 구독이 시작되는 시점에 전달되는 이벤트는 그냥 사라진다.
// - 이것이 대표적 PublishSubject의 특징
// - 이벤트가 사라지는 것이 문제가 된다면 ReplySubject를 사용하거나 holdObservable을 사용한다.
