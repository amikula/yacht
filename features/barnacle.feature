Feature: Barnacle tool
  In order to keep large configuration files under control
  As a developer using Yacht
  I want to use a tool that helps me find bloat in the configuration file

  Background:
    Given I set Yacht's YAML directory to: "yacht"
      And a file named "Rakefile" with:
      """
      require 'yacht/barnacle'
      require 'yacht/loader'

      Yacht::Loader.dir = 'yacht'

      Yacht::Barnacle::Task.new
      """

  @announce
  Scenario: Default values never overridden
    Given a file named "yacht/base.yml" with:
    """
    default:
      top_level_never_overridden: word    # A value that is never overridden
      second_level:
        never_overridden: another_word
    development:
      some_other_config: value
    production:
      second_level:
        yet_another_config: value2
    """
    When I run `rake barnacle`
    Then the output should contain:
    """
    The following keys in the default environment are never overridden, consider using a constant:
        second_level.never_overridden
        top_level_never_overridden
    """

  @announce
  Scenario: More than half of the environments override the default with the same value
    Given a file named "yacht/base.yml" with:
    """
    default:
      redundant: "no"
      nested:
        redundant: "yes"
    development:
      redundant: "yes"
      nested:
        redundant: "yes"
    test:
      redundant: "yes"
      nested:
        redundant: "no"
    production:
      redundant: "maybe"
      nested:
        redundant: "no"
    """
    When I run `rake barnacle`
    Then the output should contain these messages:
      | The value for "redundant" is often overridden to "yes", consider changing the default       |
      | The value for "nested.redundant" is often overridden to "no", consider changing the default |

  @announce
  Scenario: Any configuration values overridden with the same value they already had
    Given a file named "yacht/base.yml" with:
    """
    default:
      config: value1
    development:
      config: value1
    production:
      config: value2
      nested:
        config2: value1
    production2:
      _parent: production
      config: value2
      nested:
        config2: value1
    """
    When I run `rake barnacle`
    Then the output should contain these messages:
      | The value for "config" in the default environment is overridden to the same value in child environment development, consider removing it from the child environment |
      | The value for "nested.config2" in the production environment is overridden to the same value in child environment production2, consider removing it from the child environment |
