//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class ApplicationServiceRegistry: AbstractRegistry {

    public static var ethereumService: EthereumApplicationService {
        return service(for: EthereumApplicationService.self)
    }

}