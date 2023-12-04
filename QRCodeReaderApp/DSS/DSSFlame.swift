//
//  DSSFlame.swift
//  QRCodeReaderApp
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 04/12/23.
//

public struct DSSFlame {
    
    /// Faz as configurações inicias necessárias para o Flame poder funcioanar
    static public func initialize() {
        loadFonts()
    }
    
    /// Carrega as fontes
    static private func loadFonts() {
        DSSTypography.loadDSSFonts()
    }
}
