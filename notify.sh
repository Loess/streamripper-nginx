#!/bin/bash
[[ $CONSOLE_VERBOSE -eq 1 ]] && echo "notify.sh env:" && env
inotifywait -r -m "$1" -e create -e moved_to |
    while read dir action file; do

        [[ $CONSOLE_VERBOSE -eq 1 ]] && now="$(date +'%Y-%m-%d %H:%M:%S')" && echo "$now New file '$dir' '$file' added via '$action'"
        filenoextension="${file%.*}";

        if [[ "$file" =~ $REGEX_2_DEL && -f $dir$file ]]; then
            rm -f "$dir$file"
            echo "removed $dir$file"
            continue
        fi

        if [[ "$dir" == *"/incomplete/"* ]]; then
            [[ $DAYS_TO_KEEP_INCOMPLETE -gt 0 ]] && find "$1/incomplete" -mtime +$DAYS_TO_KEEP_INCOMPLETE -type f -delete
            if [[ "$file" =~ [[:space:]]\([0-9]+\)\. ]]; then
                continue
            fi
            if [ -f "$2/$file" ]; then
                message="Playing: <a href=\"${WEB_HREF_PREFIX}${file}\">$filenoextension</a>"
            else
                message="Recording: $filenoextension"
            fi
            curl -s -X POST "${TGBOT_URL}/sendMessage" -o /dev/null --data-urlencode "chat_id=${TGBOT_CHATID}" --data-urlencode "parse_mode=HTML" \
                --data-urlencode "text=$message"
            [[ $CONSOLE_VERBOSE -eq 1 ]] && echo "chat_id=${TGBOT_CHATID}&parse_mode=HTML&text=$message"
        else
            if [ -f "$2/$file" ]; then
                a=$(wc -c "$1/$file" | cut -d' ' -f1)
                b=$(wc -c "$2/$file" | cut -d' ' -f1)
                if [ $a -gt $b ]; then
                    mv "$1/$file" "$2"
                    [[ $CONSOLE_VERBOSE -eq 1 ]] && echo "overwrite $1/$file $a over $2/$file $b"
                else
                    rm -f "$1/$file"
                    [[ $CONSOLE_VERBOSE -eq 1 ]] && echo "remove $1/$file $a keep $2/$file $b"
                fi
            else
                mv "$1/$file" "$2"
                message="File added: <a href=\"${WEB_HREF_PREFIX}${file}\">$filenoextension</a>"
                curl -s -X POST "${TGBOT_URL}/sendMessage" -o /dev/null --data-urlencode "chat_id=${TGBOT_CHATID}" --data-urlencode "parse_mode=HTML" \
                    --data-urlencode "text=$message"
                [[ $CONSOLE_VERBOSE -eq 1 ]] && echo "chat_id=${TGBOT_CHATID}&parse_mode=HTML&text=$message"
            fi
        fi

        # end of loop

    done
