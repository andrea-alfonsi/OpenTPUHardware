`ifndef MACROS_ANNOTATIONS_SVH
`define MACROS_ANNOTATIONS_SVH

`define UNREACHABLE   $error("This statement should be unreachable, yet has been reached")
`define TODO          `TODO_MSG("Generic todo encountered. Use `TODO_MSG(MESSAGE) to insert a useful message")
`define UNIMPLEMENTED $error("Not implemented yet")

`define FIXME     $warning("Fixme encountered, error may occurs")
`define OPTIMIZE  $warning("Optimize encountered. This could be reworked in future releases. Use `OPTIMIZE_MSG(MESSAGE) to describe otpimizations required")
`define HACK      $warning("Hack encoutnered, error may occurs using non tested stacks.Use `HACK_MSG(MESSAGE) to  esplain better the hack")
`define XXX       $warning("XXX: This has multiple reason to be better in future releases")

`define HACK_MSG(MESSAGE)     $warning("Hack: %s", MESSAGE);
`define OPTIMIZE_MSG(MESSAGE) $warning("Optimization required: %s", MESSAGE)
`define TODO_MSG(MESSAGE)     $error("TODO: %s", MESSAGE)
`define NOTE(MESSAGE)         $info("This is here because sometimes an intermittent issue appears. Message: %s", MESSAGE)
`define GENERIC_ERROR(ERROR)  $error("%s", ERROR)

`endif