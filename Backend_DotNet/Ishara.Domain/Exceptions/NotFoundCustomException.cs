using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Ishara.Domain.Exceptions
{
    public class NotFoundCustomException : Exception
    {
        public NotFoundCustomException(string message) : base(message)
        { }
    }
}
