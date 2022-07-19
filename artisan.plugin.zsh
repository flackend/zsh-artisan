#--------------------------------------------------------------------------
# Laravel artisan plugin for zsh
#--------------------------------------------------------------------------
#
# This plugin adds an `artisan` shell command that will find and execute
# Laravel's artisan command from anywhere within the project. It also
# adds shell completions that work anywhere artisan can be located.

function artisan() {
    local artisan_path=`_artisan_find`

    if [ "$artisan_path" = "" ]; then
        >&2 echo "zsh-artisan: artisan not found. Are you in a Laravel directory?"
        return 1
    fi
    
    local artisan_cmd="docker-compose exec app php artisan"

    local artisan_start_time=`date +%s`

    eval $artisan_cmd $*

    local artisan_exit_status=$? # Store the exit status so we can return it later

    return $artisan_exit_status
}

compdef _artisan_add_completion artisan

function _artisan_find() {
    # Look for artisan up the file tree until the root directory
    local dir=.
    until [ $dir -ef / ]; do
        if [ -f "$dir/artisan" ]; then
            echo "$dir/artisan"
            return 0
        fi

        dir+=/..
    done

    return 1
}

function _artisan_add_completion() {
    if [ "`_artisan_find`" != "" ]; then
        compadd `_artisan_get_command_list`
    fi
}

function _artisan_get_command_list() {
    artisan --raw --no-ansi list | sed "s/[[:space:]].*//g"
}

function _docker_compose_cmd() {
    docker compose &> /dev/null
    if [ $? = 0 ]; then
        echo "docker compose"
    else
        echo "docker-compose"
    fi
}
