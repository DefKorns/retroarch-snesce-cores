/**
 * Copyright (c) 2026 DefKorns (https://defkorns.github.io/LICENSE)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#include <fcntl.h>
#include <stdarg.h>

int fcntl64(int fd, int cmd, ...)
{
   va_list ap;
   long arg;

   va_start(ap, cmd);
   arg = va_arg(ap, long);
   va_end(ap);
   return fcntl(fd, cmd, arg);
}
