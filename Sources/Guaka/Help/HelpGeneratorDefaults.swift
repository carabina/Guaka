//
//  HelpGeneratorExtension.swift
//  Guaka
//
//  Created by Omar Abdelhafith on 19/11/2016.
//
//


// MARK: - Default HelpGenerator functions implementation
extension HelpGenerator {

  init(command: Command) {
    self.init(commandHelp: CommandHelp(command: command))
  }

  var helpMessage: String {
    var ret = [String]()

    if let deprecation = deprecationSection,
      commandHelp.isDeprecated {
      ret.append(deprecation)
      ret.append("\n")
    }

    if let commandDescriptionSection = commandDescriptionSection {
      ret.append(commandDescriptionSection)
    }

    if let usageSection = usageSection {
      ret.append(usageSection)
    }

    if commandHelp.hasAliases,
      let aliases = aliasesSection {
      ret.append(aliases)
    }

    if commandHelp.hasExample,
      let exampleSection = exampleSection {
      ret.append(exampleSection)
    }

    if commandHelp.hasSubCommands,
      let subCommandsSection = subCommandsSection {
      ret.append(subCommandsSection)
    }

    if commandHelp.hasFlags,
      let flagsSection = flagsSection {
      ret.append(flagsSection)
    }

    if let informationSection = informationSection {
      ret.append(informationSection)
    }

    return ret.joined()
  }

  var errorHelpMessage: String {
    var ret = [String]()

    if let usageSection = usageSection {
      ret.append(usageSection)
    }

    if commandHelp.hasAliases,
      let aliases = aliasesSection {
      ret.append(aliases)
    }

    if commandHelp.hasExample,
      let exampleSection = exampleSection {
      ret.append(exampleSection)
    }

    if commandHelp.hasSubCommands,
      let subCommandsSection = subCommandsSection {
      ret.append(subCommandsSection)
    }

    if commandHelp.hasFlags,
      let flagsSection = flagsSection {
      ret.append(flagsSection)
    }

    if let informationSection = informationSection {
      ret.append(informationSection)
    }

    return ret.joined()
  }

  var deprecationSection: String? {
    guard let message = commandHelp.deprecationMessage else {
      return nil
    }

    return ["Command \"\(commandHelp.name)\" is deprecated, \(message)"].joined(separator: "\n")
  }

  var commandDescriptionSection: String? {
    guard let desc = commandHelp.longDescriptionMessage ?? commandHelp.shortDescriptionMessage else { return "" }
    return [desc, "\n"].joined(separator: "\n")
  }

  var usageSection: String? {
    let flagsString = commandHelp.hasFlags ? " [flags]" : ""

    var usageString = [
      "Usage:",
      "  \(commandHelp.fullUsage)\(flagsString)"
    ]

    if commandHelp.hasSubCommands {
      usageString.append("  \(commandHelp.fullName) [command]")
    }

    return (usageString + ["\n"]).joined(separator: "\n")
  }

  var aliasesSection: String? {
    if commandHelp.aliases.count == 0 { return "" }

    return [
      "Aliases:",
      "  \(commandHelp.name), \(commandHelp.aliases.joined(separator: ", "))",
      "\n"
      ].joined(separator: "\n")
  }

  var exampleSection: String? {
    guard let example = commandHelp.example else { return "" }

    return [
      "Examples:",
      example,
      "\n"
      ].joined(separator: "\n")
  }

  var subCommandsSection: String? {
    if commandHelp.hasSubCommands == false {
      return ""
    }

    let availableCommands = commandHelp.subCommands.filter { $0.isDeprecated == false }
    let sortedCommands = availableCommands.sorted { $0.0.name < $0.1.name }

    let ret = sortedCommands.reduce(["Available Commands:"]) { acc, command in
      return acc + ["  \(command.name)    \(command.shortDescriptionMessage ?? "")"]
      } + ["\n"]

    return ret.joined(separator: "\n")
  }

  var flagsSection: String? {
    let hasCommands = commandHelp.globalFlags.count + commandHelp.localFlags.count > 0
    if !hasCommands {
      return ""
    }

    var ret: [String] = []

    if let local = localFlagsSection {
      ret.append(local)
    }

    if let global = globalFlagsSection {
      ret.append(global)
    }

    return (ret + [""]).joined(separator: "\n")
  }

  var localFlagsSection: String? {
    let localFlagsDescription = FlagHelpGeneratorUtils.description(forFlags: commandHelp.localFlags)
    guard localFlagsDescription != "" else {
      return nil
    }

    return [
      "Flags:",
      localFlagsDescription,
      ""
      ].joined(separator: "\n")
  }

  var globalFlagsSection: String? {
    let globalFlagsDescription = FlagHelpGeneratorUtils.description(forFlags: commandHelp.globalFlags)
    guard globalFlagsDescription != "" else {
      return nil
    }

    return [
      "Global Flags:",
      globalFlagsDescription,
      ""
      ].joined(separator: "\n")
  }

  var informationSection: String? {
    return ["Use \"\(commandHelp.name) [command] --help\" for more information about a command."].joined(separator: "\n")
  }

  func deprecationMessage(forDeprecatedFlag flag: FlagHelp) -> String? {
    if let deprecationMessage = flag.deprecationMessage {
      return "Flag --\(flag.longName) has been deprecated, \(deprecationMessage)"
    }

    return nil
  }

}
