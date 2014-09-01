describe 'get_number'
    RET=$(get_number '1.2.3.4-0')
    assert "$RET" "1.2.3.4"

    RET=$(get_number 'v 0.01.002.0003-0')
    assert "$RET" "0.1.2.3"

    RET=$(get_number '= 4.5.09beta')
    assert "$RET" "4.5.9"

    RET=$(get_number 'v1.2.3-abc.009.00a+meta')
    assert "$RET" "1.2.3"

describe 'get_labels'
    RET=$(get_labels '1.2.3')
    assert "$RET" ""

    RET=$(get_labels 'v1.2.3')
    assert "$RET" ""

    RET=$(get_labels '1.2.3.4-1.2.3.4.a.b.c-def')
    assert "$RET" "1.2.3.4.a.b.c-def"

    RET=$(get_labels 'v1.2.3-abc.009.00a+meta')
    assert "$RET" "abc.9.00a"

    RET=$(get_labels '=4.5.09beta')
    assert "$RET" "beta"

describe 'get_metadata'
    RET=$(get_metadata '1.2.3.4-0')
    assert "$RET" ""

    RET=$(get_metadata 'v1.2.3-abc.009.00a+meta')
    assert "$RET" "meta"

describe 'get_major'
    RET=$(get_major 1.2.3.4)
    assert "$RET" "1"

describe 'get_minor'
    RET=$(get_minor 1.2.3.4)
    assert "$RET" "2"

    RET=$(get_minor 1)
    assert "$RET" "0"

describe 'get_bugfix'
    RET=$(get_bugfix 1.2.3.4)
    assert "$RET" "3"

    RET=$(get_bugfix 1)
    assert "$RET" "0"

describe 'semver_eq'
    semver_eq 1.2.3 1.2.3
    assert $? 0

    semver_eq 1.2.3 1.2.4
    assert $? 1

    semver_eq 1.2.3 1.2
    assert $? 0

    semver_eq 1.2.3 1
    assert $? 0

    semver_eq 2.2 1
    assert $? 1

describe 'semver_lt'
    semver_lt 1.2.2 1.2.3
    assert $? 0

    semver_lt 1.2.3 1.2.3
    assert $? 1

    semver_lt 1.2.4 1.2.3
    assert $? 1

describe 'semver_le'
    semver_le 1.2.2 1.2.3
    assert $? 0

    semver_le 1.2.3 1.2.3
    assert $? 0

    semver_le 1.2.4 1.2.3
    assert $? 1

describe 'semver_gt'
    semver_gt 1.2.2 1.2.3
    assert $? 1

    semver_gt 1.2.3 1.2.3
    assert $? 1

    semver_gt 1.2.4 1.2.3
    assert $? 0

describe 'semver_ge'
    semver_ge 1.2.2 1.2.3
    assert $? 1

    semver_ge 1.2.3 1.2.3
    assert $? 0

    semver_ge 1.2.4 1.2.3
    assert $? 0

describe 'regex_match'
    regex_match "1.22.333 - 1.2.3-3.2.1-a.b.c-def+011.a.1" "$RE_VER - $RE_VER"
    assert $? 0                                             "Exit code should be 0 when match"
    assert "$MATCHED_VER_1" "1.22.333"                      "Should set MATCHED_VER_1"
    assert "$MATCHED_VER_2" "1.2.3-3.2.1-a.b.c-def+011.a.1" "Should set MATCHED_VER_2"
    assert "$MATCHED_NUM_1" "1.22.333"                      "Should set MATCHED_NUM_1"
    assert "$MATCHED_NUM_2" "1.2.3"                         "Should set MATCHED_NUM_2"

    regex_match '1.2.3 - 5.6.7' '5.6.7'
    assert $? 1                                             "Exit code should be 1 when don't match"
    assert "$MATCHED_VER_1" ""                              "When don't match MATCHED_VER_x should be empty"
    assert "$MATCHED_VER_1" ""                              "When don't match MATCHED_NUM_x should be empty"

describe 'reslove_rule'
    RET=$(resolve_rule 'v1.2.3')
    assert "$RET" "eq 1.2.3"                                "Specific (v1.2.3)"

    RET=$(resolve_rule '1')
    assert "$RET" "eq 1"                                    "Specific (1)"

    RET=$(resolve_rule '=1.2.3-a.2-c')
    assert "$RET" "eq 1.2.3"                                "Specific (=1.2.3-a.2-c)"

    RET=$(resolve_rule '>1.2.3')
    assert "$RET" "gt 1.2.3"                                "Greater than (>1.2.3)"

    RET=$(resolve_rule '<1.2.3')
    assert "$RET" "lt 1.2.3-0"                              "Less than (<1.2.3)"

    RET=$(resolve_rule '>=1.2.3')
    assert "$RET" "ge 1.2.3"                                "Greater than or equal to (>=1.2.3)"

    RET=$(resolve_rule '<=1.2.3')
    assert "$RET" "le 1.2.3"                                "Less than or equal to (<=1.2.3)"

    RET=$(resolve_rule '1.2.3 - 4.5.6')
    assert "$RET" "ge 1.2.3\nle 4.5.6"                      "Range (1.2.3 - 4.5.6)"

    RET=$(resolve_rule '>1.2.3 <4.5.6')
    assert "$RET" "gt 1.2.3\nlt 4.5.6-0"                    "Range (>1.2.3 <4.5.6)"

    RET=$(resolve_rule '>1.2.3 <=4.5.6')
    assert "$RET" "gt 1.2.3\nle 4.5.6"                      "Range (>1.2.3 <=4.5.6)"

    RET=$(resolve_rule '>=1.2.3 <4.5.6')
    assert "$RET" "ge 1.2.3\nlt 4.5.6-0"                    "Range (>=1.2.3 <4.5.6)"

    RET=$(resolve_rule '>=1.2.3 <=4.5.6')
    assert "$RET" "ge 1.2.3\nle 4.5.6"                      "Range (>=1.2.3 <=4.5.6)"

    RET=$(resolve_rule '~1.2.3')
    assert "$RET" "ge 1.2.3\nlt 1.3.0-0"                    "Tilde (~1.2.3)"

    RET=$(resolve_rule '*')
    assert "$RET" "ge 0.0.0-0"                              "Wildcard (*)"

    RET=$(resolve_rule '1.2.x')
    assert "$RET" "eq 1.2"                                  "Wildcard (1.2.x)"

    RET=$(resolve_rule '1.*')
    assert "$RET" "eq 1"                                    "Wildcard (1.*)"

    #RET=$(resolve_rule '^1.2.3')
    #assert "$RET" "caret 1.2.3"                             "Caret (^1.2.3)"

describe 'normalize_rules'
    RET="$(normalize_rules '  \t  >\t\t1.2.3.4-abc.def+a   \t 123.123   -\t\t\t  v5.3.2  ~ \tv5.5.x  ')"
    assert "$RET" '>1.2.3.4-abc.def+a 123.123_-_5.3.2 ~5.5.*'

describe 'read_rule'
    read_rule '~1.2.3 4.5.6_-_7.8.9 *' rule
    assert $? 0                                             'Read 1st rule - should return true'
    assert $RULEIND 1                                       'Read 1st rule - $RULEIND should be 1'
    assert "$rule" "~#"                                     'Read 1st rule - $rule should be "~#"'
    assert "$RULEVER_1" "1.2.3"                             'Read 1st rule - $RULEVER_1 should be "1.2.3"'

    read_rule '~1.2.3 4.5.6_-_7.8.9 *' rule
    assert $? 0                                             'Read 2nd rule - should return true'
    assert $RULEIND 2                                       'Read 2nd rule - $RULEIND should be 2'
    assert "$rule" "#_-_#"                                  'Read 2nd rule - $rule should be "#_-_#"'
    assert "$RULEVER_1" "4.5.6"                             'Read 2nd rule - $RULEVER_1 should be "4.5.6"'
    assert "$RULEVER_2" "7.8.9"                             'Read 2nd rule - $RULEVER_1 should be "7.8.9"'

    read_rule '~1.2.3 4.5.6_-_7.8.9 *' rule
    assert $? 0                                             'Read 3rd rule - should return true'
    assert $RULEIND 3                                       'Read 3rd rule - $RULEIND should be 3'
    assert "$rule" "*"                                      'Read 3rd rule - $rule should be "*"'

    read_rule '~1.2.3 4.5.6_-_7.8.9 *' rule
    assert $? 1                                             'Read 4th rule - should return false'
