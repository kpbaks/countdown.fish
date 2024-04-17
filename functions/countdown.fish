function countdown -d 'print a colorful countdown, to remind you about your deadlines'
    set -l options h/help s/start= e/end= t/title= l/loop S/sleep=
    if not argparse $options -- $argv
        printf '\n'
        eval (status function) --help
        return 2
    end

    set -l reset (set_color normal)
    set -l bold (set_color --bold)
    set -l italics (set_color --italics)
    set -l red (set_color red)
    set -l green (set_color green)
    set -l yellow (set_color yellow)
    set -l blue (set_color blue)
    set -l cyan (set_color cyan)
    set -l magenta (set_color magenta)

    set -l strftime "%a %H:%M:%S %Y-%m-%d"

    set -l now (date +%s)

    if set --query _flag_help
        set -l option_color (set_color $fish_color_option)
        set -l value_color (set_color $fish_color_param)
        set -l reset (set_color normal)
        set -l bold (set_color --bold)
        set -l section_header_color (set_color yellow)

        set -l example_start "2024-01-29 12:00"
        set -l example_end "2024-06-04 12:00"
        printf '%sprint a colorful countdown, to remind you about your deadlines%s\n' $bold $reset
        printf '\n'
        printf '%sUSAGE:%s %s%s%s %s-s%s <%sTIME%s> %s-e%s <%sTIME%s> [OPTIONS]\n' $section_header_color $reset (set_color $fish_color_command) (status function) $reset $option_color $reset $value_color $reset $option_color $reset $value_color $reset
        printf '\n'
        printf '%sOPTIONS:%s\n' $section_header_color $reset
        printf '\t%s-h%s, %s--help%s           show this help message and return\n' $option_color $reset $option_color $reset
        printf '\t%s-s%s, %s--start%s <%sTIME%s>   unix timestamp or datetime string e.g. %s"%s"%s\n' $option_color $reset $option_color $reset $value_color $reset (set_color $fish_color_quote) $example_start $reset
        printf '\t%s-e%s, %s--end%s   <%sTIME%s>   unix timestamp or datetime string e.g. %s"%s"%s\n' $option_color $reset $option_color $reset $value_color $reset (set_color $fish_color_quote) $example_end $reset
        printf '\t%s-t%s, %s--title%s <%sTITLE%s>  optional title string for the countdown\n' $option_color $reset $option_color $reset $value_color $reset
        printf '\t%s-l%s, %s--loop%s           loop the countdown every %s--sleep%s <%sAMOUNT%s> seconds\n' $option_color $reset $option_color $reset $option_color $reset $value_color $reset
        printf '\t%s-S%s, %s--sleep%s <%sAMOUNT%s> seconds to sleep between updates [default: 1]\n' $option_color $reset $option_color $reset $value_color $reset

        printf '\n'
        printf '%sEXAMPLES:%s\n' $section_header_color $reset
        printf '\t%s%s\n' (printf (echo 'countdown -s "2024-01-29 12:00" -e "2024-06-04 12:00" -t "Master Thesis Hand-in Deadline"' | fish_indent --ansi)) $reset
        printf '\t%s%s\n' (printf (echo 'countdown -s "2024-01-29 12:00" -e "2024-06-04 12:00" -t "Master Thesis Hand-in Deadline" -l --sleep 5' | fish_indent --ansi)) $reset
        printf '\n'

        # TODO: document env vars

        printf 'Part if %scountdown.fish%s. A plugin for the %s><>%s shell.\n' $green $reset $blue $reset
        printf 'See %shttps://github.com/kpbaks/countdown.fish%s for more information, and if you like it, please give it a ⭐\n' (set_color cyan --underline) $reset
        return 0
    end >&2

    if not set --query _flag_start
        return 2
    end
    if string match --regex --quiet '^\d+$' -- $_flag_start
        set -f start_unix_timestamp $_flag_start
    else
        set -f start_unix_timestamp (date --date "$_flag_start" +%s)
    end

    if not set --query _flag_end
        return 2
    end
    if string match --regex --quiet '^\d+$' -- $_flag_end
        set -f end_unix_timestamp $_flag_end
    else
        set -f end_unix_timestamp (date --date "$_flag_end" +%s)
    end

    if set --query COUNTDOWN_COLORS
        set -f colors $COUNTDOWN_COLORS
    else
        # colors generated with:
        # `pastel gradient '#00ff00' '#ff0000' -s HSL -n 20 | pastel format hex`
        set -f colors "#00ff00" "#1aff00" "#37ff00" "#51ff00" "#6aff00" "#88ff00" "#a2ff00" "#bbff00" "#d9ff00" "#f2ff00" "#fff200" "#ffd900" "#ffbb00" "#ffa200" "#ff8800" "#ff6a00" "#ff5100" "#ff3700" "#ff1900" "#ff0000"
    end
    # set -l colors "#ff0000" "#ff1900" "#ff3700" "#ff5100" "#ff6a00" "#ff8800" "#ffa200" "#ffbb00" "#ffd900" "#fff200" "#f2ff00" "#d9ff00" "#bbff00" "#a2ff00" "#88ff00" "#6aff00" "#51ff00" "#37ff00" "#1aff00" "#00ff00"

    if test $now -gt $end_unix_timestamp
        printf '%serror%s: the end time `--end "%s%s%s"` is in the past, compared to now: %s%s%s\n' $red $reset (set_color $colors[-1]) (date -d @$end_unix_timestamp +"$strftime") $reset $blue (date --date @$now +"$strftime") $reset
        printf '\n%shint%s:  try %s%s\n' (set_color magenta) (set_color normal) (printf (echo "$(status function) --help" | fish_indent --ansi)) (set_color normal)
        return 2
    end

    if test $now -lt $start_unix_timestamp
        printf '%serror%s: the start time `--start "%s%s%s"` is in the future, compared to now: %s%s%s\n' $red $reset (set_color $colors[1]) (date -d @$start_unix_timestamp +"$strftime") $reset $blue (date --date @$now +"$strftime") $reset
        printf '\n%shint%s:  try %s%s\n' (set_color magenta) (set_color normal) (printf (echo "$(status function) --help" | fish_indent --ansi)) (set_color normal)
        return 2
    end

    set -l duration (math "$end_unix_timestamp - $start_unix_timestamp")

    if not set --query _flag_sleep
        set -f _flag_sleep 1
    end

    if set --query _flag_loop
        # NOTE: defer keyword would be nice for this
        printf "\e[?25l" # hide cursor
        function __restore_cursor --on-event fish_prompt
            printf "\e[?25h" # restore cursor
            functions --erase (status function) # erase hook
        end
    end

    if not string match --regex --quiet '^\d+$' -- $_flag_sleep
        printf '%serror%s: `--sleep <AMOUNT>` must be a number, got: %s%s%s\n' $red $reset $red $_flag_sleep $reset
        return 2
    end

    while true

        set -l now (date +%s)
        set -l seconds_left (math "$duration - ($now - $start_unix_timestamp)")
        set -l ratio_passed (math "($duration - $seconds_left) / $duration")
        set -l ratio_left (math "1.0 - $ratio_passed")


        set -l bar_passed_color (set_color $colors[(math "floor($ratio_passed * $(count $colors))")])

        # set -l bar_passed (string repeat --count (math "floor($ratio_passed * ($COLUMNS - 2))") '-')
        # set -l bar_left (string repeat --count (math "$COLUMNS - 2 - $(string length -- $bar_passed)") ' ')
        # printf '[%s%s%s%s]\n' (set_color $bar_passed_color) $bar_passed $reset $bar_left



        if set --query _flag_title
            printf '%s%s%s\n' (set_color --bold --italics magenta) $_flag_title $reset
        end


        # printf 'start:      %s%s%s\n' (set_color $colors[1]) (date -d @$start_unix_timestamp +"$strftime") $reset
        # printf 'end:        %s%s%s\n' (set_color $colors[-1]) (date --date @$end_unix_timestamp +"$strftime") $reset
        # TODO: use US locale
        printf 'start:      %s%s%s\n' $green (date -d @$start_unix_timestamp +"$strftime") $reset
        printf 'end:        %s%s%s\n' $red (date --date @$end_unix_timestamp +"$strftime") $reset
        printf 'time total: %s%s%s\n' $green (peopletime (math "$duration * 1000")) $reset
        printf 'time left:  %s%s%s\n' $bar_passed_color (peopletime (math "$seconds_left * 1000")) $reset

        set -l percentage_passed (LC_NUMERIC="en_US.UTF-8" printf '%05.2f' (math "$ratio_passed * 100.0"))

        set -l bar_passed (string repeat --count (math "floor($ratio_passed * ($COLUMNS))") '█')
        set -l bar_left (string repeat --count (math "$COLUMNS - $(string length -- $bar_passed)") ' ')

        begin
            set -l r_offset 2
            set -l msg_without_color (printf '%s%% of the time has passed!' $percentage_passed)
            set -l msg (printf '%s%s%%%s of the time has passed!\n' $bar_passed_color $percentage_passed $reset)
            # echo "columns: $COLUMNS"
            # echo "#bar_passed: $(string length $bar_passed)"
            # echo "r_offset: $r_offset"
            # echo "#msg: $(string length $msg)"
            # echo "#msg_without_color: $(string length $msg_without_color)"

            if test (math "$(string length $bar_passed) + $r_offset + $(string length $msg_without_color)") -gt $COLUMNS
                string pad -w $COLUMNS -- $msg
            else
                printf '%s%s\n' (string repeat --count (math "$(string length $bar_passed) + $r_offset") ' ') $msg
            end
        end

        # LC_NUMERIC="en_US.UTF-8" printf '%06.2f\n' 4.0023

        # set -l bar_passed_color (set_color $colors[(math "floor($ratio_passed * $(count $colors))")])

        # COLUMNS:
        # percentage_passed: [0,1]
        # n_colors:

        set -l n (math "floor($ratio_passed * $(count $colors))")
        # echo "n: $n"
        set -l width (math "floor($COLUMNS / $(count $colors))")
        for i in (seq $n)
            # set -l width 6
            # echo "color: $colors[$i]"
            printf '%s%s' (set_color $colors[$i]) (string repeat --count $width '█')
        end

        printf '%s\n' $bar_left
        # printf '%s%s%s%s\n' $bar_passed_color $bar_passed $reset $bar_left

        if set --query _flag_loop
            sleep $_flag_sleep
            set -l n_lines 7
            # Move cursor up n_lines lines to overwrite previous output next iteration
            for i in (seq 1 $n_lines)
                printf "\033[1A"
            end
        else
            break
        end

    end

    printf "\e[?25h" # restore cursor
    functions --erase __countdown_restore_cursor

    return 0
end
