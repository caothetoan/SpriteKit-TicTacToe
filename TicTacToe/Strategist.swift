/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import GameplayKit

//
struct Strategist {
  
    // The look ahead depth is the constraint you give a strategist to limit the number of future moves it can simulate. You also provide a random source to be the deciding factor when the strategist selects multiple moves as the best move
    private let strategist: GKMinmaxStrategist = {
        let strategist = GKMinmaxStrategist()
        /**
         * The maximum number of future turns that will be processed when searching for a move.
         */
        strategist.maxLookAheadDepth = 5
        strategist.randomSource = GKARC4RandomSource()
        
        return strategist
    }()
    
    // reference to the game model you defined and supply that to the strategist.
    var board: Board {
        didSet {
            strategist.gameModel = board
        }
    }
    // a CGPoint representing the strategist’s best move. The bestMove(for:) method will return nil if the player is in an invalid state or nonexistent.
    var bestCoordinate: CGPoint? {
        /**
        * Selects the best move for the specified player. If randomSource is not nil, it will randomly select
        * which move to use if there are one or more ties for the best. Returns nil if the player is invalid,
        * the player is not a part of the game model, or the player has no valid moves available.
        */
        if let move = strategist.bestMove(for: board.currentPlayer) as? Move {
            return move.coordinate
        }
        
        return nil
    }
    
}
