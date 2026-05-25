# UVM UART Verification

## 프로젝트 개요

UART 송수신 모듈을 UVM 기반 testbench로 검증한 프로젝트입니다.
Sequence, driver, monitor, scoreboard 구조를 사용해 TX/RX/loopback 시나리오를 나누어 확인합니다.

## 목표 동작

- UART TX 단독 동작을 sequence 기반 stimulus로 검증합니다.
- UART RX 입력을 driver가 생성하고 monitor가 수집합니다.
- Loopback 시나리오에서 송신 데이터와 수신 데이터를 scoreboard로 비교합니다.
- Base, TX, RX, loopback test를 분리해 선택적으로 실행할 수 있습니다.

## 기술 스택

| 구분 | 내용 |
| --- | --- |
| 핵심 개념 | UVM, sequence item, sequence, driver, monitor, scoreboard, agent, environment |
| 검증 대상 | UART TX/RX |
| 사용 언어 | SystemVerilog |
| 사용 도구 | UVM 1.2 기반 simulator, Verdi/파형 디버깅 환경 |

## 시스템 구조

```text
tb_uart
├─ uart
├─ uart_interface
└─ uart_env
   ├─ uart_agent
   │  ├─ sequencer
   │  ├─ uart_driver
   │  └─ uart_monitor
   └─ uart_scoreboard

uart_test
├─ uart_base_test
├─ uart_tx_test
├─ uart_rx_test
└─ uart_loopback_test
```

- `uart_seq_item`: UART transaction 단위 데이터를 정의합니다.
- `uart_sequence`: TX, RX, loopback 검증용 stimulus를 생성합니다.
- `uart_driver`: sequence item을 받아 DUT 입력 신호로 변환합니다.
- `uart_monitor`: DUT 출력과 bus 상태를 관찰해 transaction으로 복원합니다.
- `uart_scoreboard`: 예상 데이터와 실제 결과를 비교합니다.
- `uart_env`: agent와 scoreboard를 묶는 검증 환경입니다.

## 검증 방식

- TX/RX 단독 test와 loopback test를 분리했습니다.
- Monitor가 수집한 transaction을 scoreboard에서 비교하여 pass/fail을 판단합니다.

## 실행 방법

Synopsys VCS와 UVM 1.2 환경에서 실행하는 기준입니다.

```bash
make sim_base
make sim_tx
make sim_rx
make sim_loopback
make verdi
make clean
```
