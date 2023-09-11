//
//  main.swift
//  Only pawns chess game
//
//  Created by Sergey Ivanov on 05.09.2023.
//

import Cocoa
import Foundation


class Pawn {
    var isFirstMove: Bool = true
    var pastPosition: String? = nil
    var currentPosition: String?
    var Side: Side
    var potensialNextPosition: String = " "
    
    init (currentPosition: String, Side: Side) {
        self.Side = Side
        
        self.currentPosition = currentPosition
    }
    
    func setPosition (_ nextPosition: String) {
        self.currentPosition = nextPosition
    }
}

class ChessDesk {
    
    var lastMovingPawn: Pawn?
    
    init(lastMovingPawn: Pawn? = nil) {
        self.lastMovingPawn = lastMovingPawn
    }
    
}

enum Side: String {
    case white = "W"
    case black = "B"
    case nothing = " "
}

enum ResultsOfGame: String {
    case userWins
    case enemyWins
    case stalemate = "Stalemate! Good result, friend!"
    case continueGame = "Continue game"
}

var numberOfMove: Int = 0

var dictIntToStr = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e", 6: "f", 7: "g", 8: "h"]
var dictStrToInt = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7, "h": 8]

var blackPawnsArray: [Pawn] = []
var whitePawnsArray: [Pawn] = []

var currentTurnSide: String = Side.white.rawValue
var inputMove: String?

var numberOfWhitePawnsCut: Int {
    whitePawnsArray.filter { $0.currentPosition != nil }.count
}
var numberOfBlackPawnsCut: Int {
    return blackPawnsArray.filter { $0.currentPosition != nil }.count
}

var chessDesk = Array(repeating: Array(repeating: Side.nothing.rawValue, count: 8), count: 8)

var patternInputMove: String = "[a-hA-H][1-8][a-hA-H][1-8]"

var stateOfGame: ResultsOfGame = ResultsOfGame.continueGame

var firstPlayerName: String?
var secondPlayerName: String?

var gameHasBeenLaunched: Bool = false
let currentDesk = ChessDesk()

// флаг логики взятия на проходе
var isCapturingOnAisle = false

func initializeGame() {
    
    if !gameHasBeenLaunched {
        print("Hello, friends! Welcome on only pawns chess game! \nPlease, enter your names...\n")
    
        repeat {
            print("First player's name:", terminator: " ")
            firstPlayerName = readLine()
            if firstPlayerName == "" {
                print("You entered incorrect name :( Please, try again\n")
            }
        } while firstPlayerName == ""
        
        repeat {
            print("Second player's name:", terminator: " ")
            secondPlayerName = readLine()
            if secondPlayerName == "" {
                print("You entered incorrect name :( Please, try again\n")
            }
        } while secondPlayerName == ""
        
        for i in 1...8 {
            let blackPawn = Pawn(currentPosition: "\(dictIntToStr[i]!)7", Side: .black)
            let whitePawn = Pawn(currentPosition: "\(dictIntToStr[i]!)2", Side: .white)
            blackPawnsArray.append(blackPawn)
            whitePawnsArray.append(whitePawn)
        }
        
        gameHasBeenLaunched = true
    }
    
    for element in blackPawnsArray + whitePawnsArray {
        if let currentPositionOfPawn = element.currentPosition {
            let raw = 8 - Int(currentPositionOfPawn.suffix(1))!
            let column = dictStrToInt[String(currentPositionOfPawn.prefix(1))]! - 1
            chessDesk[raw][column] = element.Side.rawValue
        } else { continue }
        
    }
    
    print("\n   +---+---+---+---+---+---+---+---+")
    for i in 0...7 {
        print("\(8 - i)  | \(chessDesk[i][0]) | \(chessDesk[i][1]) | \(chessDesk[i][2]) | \(chessDesk[i][3]) | \(chessDesk[i][4]) | \(chessDesk[i][5]) | \(chessDesk[i][6]) | \(chessDesk[i][7]) |")
        print("   +---+---+---+---+---+---+---+---+")
    }
    print("     a   b   c   d   e   f   g   h\n")
}

func checkWinOrStalemate() -> String {
    
    if numberOfBlackPawnsCut == numberOfWhitePawnsCut {
        let whiteAvailablePawns =  whitePawnsArray.filter { $0.currentPosition != nil }
        var numberOfBlockPawns = 0
        for item in whiteAvailablePawns {
            
            var hasEnemyPawnsForCut: Bool {
                if item.currentPosition!.prefix(1) == "a" || item.currentPosition!.prefix(1) == "h" {
                    return item.currentPosition!.prefix(1) == "a" ? chessDesk[8 - Int(item.potensialNextPosition.suffix(1))!][dictStrToInt[String(item.potensialNextPosition.prefix(1))]!] == " " : chessDesk[8 - Int(item.potensialNextPosition.suffix(1))!][dictStrToInt[String(item.potensialNextPosition.prefix(1))]! - 2] == " "
                } else {
                    return chessDesk[8 - Int(item.potensialNextPosition.suffix(1))!][dictStrToInt[String(item.potensialNextPosition.prefix(1))]! - 2] == " " || chessDesk[8 - Int(item.potensialNextPosition.suffix(1))!][dictStrToInt[String(item.potensialNextPosition.prefix(1))]!] == " "
                }
            }
            if !blackPawnsArray.filter( {$0.currentPosition == item.potensialNextPosition} ).isEmpty && !hasEnemyPawnsForCut {
                numberOfBlockPawns += 1
            }
        }
        stateOfGame = numberOfBlockPawns == numberOfBlackPawnsCut ? ResultsOfGame.stalemate : ResultsOfGame.continueGame
    }
    
    if currentTurnSide == Side.white.rawValue || blackPawnsArray.filter({ $0.currentPosition != nil }).isEmpty {
        if chessDesk.first!.contains("W") {
            stateOfGame = .userWins
            print("White pawns win")
        }
    } else {
        if chessDesk.last!.contains("B") || whitePawnsArray.filter({ $0.currentPosition != nil }).isEmpty {
            stateOfGame = .enemyWins
            print("Black pawns win")
        }
    }
    return stateOfGame.rawValue
}

func findElement(in list: [Pawn], matching condition: (Pawn) -> Bool) -> Pawn? {
    for item in list {
        if condition(item) {
            return item
        }
    }
    return nil
}

func checkOnValidMove(_ inputMove: String) -> Bool {
    let regexTest = NSPredicate(format: "SELF MATCHES %@", patternInputMove)
    return regexTest.evaluate(with: inputMove)
}

func checkToRightMove(_ currentPosition: String, _ nextPosition: String, _ side: String) -> Bool {
    
    // поверка валидности текущей позиции
    func checkExistPawn() -> Bool {
        return side == Side.white.rawValue ? whitePawnsArray.contains { $0.currentPosition == currentPosition } : blackPawnsArray.contains { $0.currentPosition == currentPosition }
    }
    
    // проверка валидности следующей позиции
    func checkValidNextPosition () -> Bool {
        
        let activePawn = findElement(in: blackPawnsArray + whitePawnsArray) { element in
            return element.currentPosition == currentPosition
        }
        
        if let activePawn = activePawn {
            let contentOfCellNextPositionOnDesk = chessDesk[8 - Int(nextPosition.suffix(1))!][dictStrToInt[String(nextPosition.prefix(1))]! - 1]
            // проверка на то, что следующая позиция на доске не занята своей же пешкой
            let pawnInNextPositionIsNotSame = contentOfCellNextPositionOnDesk != side
            // модуль разницы между номерами строк для задания дальности ходьбы пешек
            let diffBetweenNextAndCurrentRaws = { (nextPos: String, currentPos: String) -> Int in
                return abs(Int(nextPos.suffix(1))! - Int(currentPos.suffix(1))!)
            }
            // модуль разницы между номерами столбцов для задания дальности ходьбы пешек
            let diffBetweenNextAndCurrentColumns = { (nextPos: String, currentPos: String) -> Int in
                return abs(dictStrToInt[String(nextPos.prefix(1))]! - dictStrToInt[String(currentPos.prefix(1))]!)
            }
            // проверка на то, что при ходьбе вперед на одну ячейку нет других пешек
            let notDiffPawnsInFrontOfCurrentPawn = {
                if diffBetweenNextAndCurrentColumns(nextPosition, currentPosition) == 0 && diffBetweenNextAndCurrentRaws(nextPosition, currentPosition) == 1 {
                    
                    return activePawn.Side.rawValue == Side.white.rawValue ? contentOfCellNextPositionOnDesk != Side.black.rawValue : contentOfCellNextPositionOnDesk != Side.white.rawValue
                } else { return true }
            }
                
                let correctDiagonalMove = {
                    if diffBetweenNextAndCurrentColumns(nextPosition, currentPosition) == 1 {
                        // обработка корректности взятия на проходе
                        // если ячейка над/под следующей ячейкей является предыдущей позицией последней пешки и она прошла два хода, то это кейс взятия на проходе
                        if "\(nextPosition.prefix(1))\(side == Side.white.rawValue ? Int(nextPosition.suffix(1))! + 1 : Int(nextPosition.suffix(1))! - 1)" == currentDesk.lastMovingPawn?.pastPosition && diffBetweenNextAndCurrentRaws(currentDesk.lastMovingPawn!.currentPosition!, currentDesk.lastMovingPawn!.pastPosition!
                        ) == 2 {
                            isCapturingOnAisle = true
                            return true
                        }
                        // обработка корректности кейса сруба
                        if activePawn.Side.rawValue == Side.white.rawValue {
                            return contentOfCellNextPositionOnDesk == Side.black.rawValue
                        } else {
                            return contentOfCellNextPositionOnDesk == Side.white.rawValue
                        }
                    } else { return true }
                }
                
                let nextPositionIsNotBackStep = {
                    if activePawn.Side.rawValue == Side.white.rawValue {
                        return Int(nextPosition.suffix(1))! - Int(currentPosition.suffix(1))! > 0 ? true : false
                    } else {
                        return Int(nextPosition.suffix(1))! - Int(currentPosition.suffix(1))! < 0 ? true : false
                    }
                }
                
                if activePawn.isFirstMove {
                    let conditional = (diffBetweenNextAndCurrentColumns(nextPosition, currentPosition) == 0) && (diffBetweenNextAndCurrentRaws(nextPosition, currentPosition) <= 2) && pawnInNextPositionIsNotSame && nextPositionIsNotBackStep() && notDiffPawnsInFrontOfCurrentPawn() && correctDiagonalMove()
                    
                    return conditional ? true : false
                } else {
                    let conditional = (diffBetweenNextAndCurrentColumns(nextPosition, currentPosition) <= 1) && (diffBetweenNextAndCurrentRaws(nextPosition, currentPosition) == 1) && pawnInNextPositionIsNotSame && nextPositionIsNotBackStep() && notDiffPawnsInFrontOfCurrentPawn() && correctDiagonalMove()
                    
                    return conditional ? true : false
                }
                
            }
            
            return true
        }
        
        return checkExistPawn() && checkValidNextPosition() ? true : false
    }
    
    func makeMove(_ currentPosition: String, _ nextPosition: String) {
        
        let currentMovingPawn: Pawn = findElement(in: blackPawnsArray + whitePawnsArray, matching: {$0.currentPosition == currentPosition})!
        
        let nextRaw = 8 - Int(nextPosition.suffix(1))!
        let nextColumn = dictStrToInt[String(nextPosition.prefix(1))]! - 1
        
        let lastRaw = 8 - Int(currentPosition.suffix(1))!
        let lastColumn = dictStrToInt[String(currentPosition.prefix(1))]! - 1
        
        // обработка кейса сруба пешки
        if abs(nextColumn - lastColumn) == 1 {
            let activePawn = findElement(in: blackPawnsArray + whitePawnsArray) { element in
                return element.currentPosition == nextPosition
            }
            if let activePawn = activePawn {
                activePawn.currentPosition = nil
                print("\(currentTurnSide) has cut down the enemy's pawn in cell \(nextPosition)")
                activePawn.Side.rawValue == Side.black.rawValue ? print("Black pawns left: \(numberOfBlackPawnsCut)") : print("White pawns left: \(numberOfBlackPawnsCut)")
            } else if isCapturingOnAisle {
                let felledPawn = findElement(in: blackPawnsArray + whitePawnsArray) { element in
                    return element.pastPosition == currentDesk.lastMovingPawn?.pastPosition
                }
                chessDesk[8 - Int(felledPawn!.currentPosition!.suffix(1))!][dictStrToInt[String(felledPawn!.currentPosition!.prefix(1))]! - 1] = Side.nothing.rawValue
                felledPawn?.currentPosition = nil
                print("\(currentTurnSide) has cut down the enemy's pawn in cell \(nextPosition)")
                isCapturingOnAisle = false
            }
        }
        
        chessDesk[nextRaw][nextColumn] = currentMovingPawn.Side.rawValue
        currentMovingPawn.pastPosition = currentMovingPawn.currentPosition
        currentMovingPawn.currentPosition = nextPosition
        let potensialNextRaw = currentMovingPawn.Side == .white ? 9 - Int(nextPosition.suffix(1))! : 7 - Int(nextPosition.suffix(1))!
        currentMovingPawn.potensialNextPosition = "\(String(nextPosition.prefix(1)))\(potensialNextRaw)"
        currentMovingPawn.isFirstMove = false
        currentDesk.lastMovingPawn = currentMovingPawn
        
        
        chessDesk[lastRaw][lastColumn] = Side.nothing.rawValue
    }
    
main: while true {
    
    initializeGame()
    
    repeat {
        currentTurnSide == Side.white.rawValue ? print("\(firstPlayerName!)'s turn:", terminator: " ") : print("\(secondPlayerName!)'s turn:", terminator: " ")
        inputMove = readLine()
        
        if checkOnValidMove(inputMove!) {
            
            let currentPosition = String(inputMove!.prefix(2))
            let nextPosition = String(inputMove!.suffix(2))
            
            if checkToRightMove(currentPosition, nextPosition, currentTurnSide) {
                
                makeMove(currentPosition, nextPosition)
                
                if checkWinOrStalemate() != ResultsOfGame.continueGame.rawValue {
                    initializeGame()
                    break main
                }
                
                currentTurnSide = currentTurnSide == Side.white.rawValue ? Side.black.rawValue : Side.white.rawValue
                numberOfMove += 1
                
            } else {
                print("Impossible move. Please, try again.\n")
            }
        } else {
            print("Invalid input. Please, try again.\n")
        }
        
    } while !checkOnValidMove(inputMove!)
}
